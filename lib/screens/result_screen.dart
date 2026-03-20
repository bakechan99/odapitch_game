import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../constants/texts.dart';
import 'settings_screen.dart';
import 'presentation_screen.dart';
import 'voting_screen.dart';
import 'result_view.dart';
import 'passing_confirm_screen.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/passing_style_card.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../features/game_session/application/result_session_controller.dart';

import '../services/api_service.dart';
import '../models/card_data.dart';
//import '../models/placed_card.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;
  final String odaiTheme;
  final String odaiId;
  final bool isAiEnabled; // ← 追加

  const ResultScreen({
    super.key,
    required this.players,
    required this.settings,
    required this.odaiTheme,
    required this.odaiId,
    this.isAiEnabled = false, // ← 追加
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ResultSessionController _controller;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _aiHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ResultSessionController(
      players: widget.players,
      presentationTimeSec: widget.settings.presentationTimeSec,
      qaTimeSec: widget.settings.qaTimeSec,
      isAiEnabled: widget.isAiEnabled, // ← コントローラへ渡す
      titleScorer: (title) =>
          ApiService.getTitleScore(title, mode: widget.odaiId),
      onTimeUp: _playSound,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _aiHorizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmDialog({
    required String title,
    String? content,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PassingConfirmScreen(title: title, content: content ?? ""),
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  void _onHomePressed() {
    _showConfirmDialog(
      title: AppTexts.checkPop,
      content: AppTexts.cautionBackHome,
      onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/timeup.mp3'));
    } catch (e) {
      debugPrint("音声ファイルエラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // AI採点中（通信中）は元のリッチなローディング画面を表示
        if (_controller.isFetchingAI) {
          return Scaffold(
            backgroundColor: AppColors.themePrimaryLight,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          color: AppColors.themePrimaryDark,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'AI採点中...',
                        style: AppTextStyles.headingPrimaryLarge.copyWith(
                          fontSize: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "サーバーと通信しています。しばらくお待ちください。",
                    style: AppTextStyles.headingSection.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          );
        }

        switch (_controller.currentPhase) {
          case ScreenPhase.presentationStandby:
            return _buildStandbyScreen(
              player: widget.players[_controller.currentPresenterIndex],
              message: AppTexts.nextPresenter,
              onReady: _controller.startPresentation,
            );
          case ScreenPhase.presentation:
            return PresentationScreen(
              player: widget.players[_controller.currentPresenterIndex],
              isPresentationMode: _controller.isPresentationMode,
              isTimerRunning: _controller.isTimerRunning,
              timeLeft: _controller.timeLeft,
              qaTimeLeft: _controller.qaTimeLeft,
              settings: widget.settings,
              onHomePressed: _onHomePressed,
              toggleTimer: _controller.toggleTimer,
              proceedToNextStep: _controller.proceedToNextStep,
              onResetTimer: _controller.resetTimer,
              isLastPresenter:
                  _controller.currentPresenterIndex ==
                  widget.players.length - 1,
            );
          case ScreenPhase.votingStandby:
            return _buildStandbyScreen(
              player: widget.players[_controller.currentVoterIndex],
              message: AppTexts.nextVoter,
              onReady: _controller.startVoting,
            );
          case ScreenPhase.voting:
            return VotingScreen(
              players: widget.players,
              currentVoterIndex: _controller.currentVoterIndex,
              currentAllocation: _controller.currentAllocation,
              onHomePressed: _onHomePressed,
              onAllocationChanged: _controller.setAllocation,
              onIncrement: _controller.incrementAllocation,
              onDecrement: _controller.decrementAllocation,
              submitVote: () => _showConfirmDialog(
                title: AppTexts.voteConfirmTitle,
                content: AppTexts.checkBudget,
                onConfirm: () {
                  _controller.submitVote();
                },
              ),
            );
          case ScreenPhase.result:
            return ResultView(
              players: widget.players,
              odaiTheme: widget.odaiTheme,
              voteMatrix: _controller.voteMatrix,
              aiResults: _controller.aiResults,
              getPlayerColor: _getPlayerColor,
              onHomePressed: _onHomePressed,
            );
        }
      },
    );
  }

  Widget _buildStandbyScreen({
    required Player player,
    required String message,
    required VoidCallback onReady,
  }) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: AppColors.surfaceTheme)),
          Center(
            child: PassingStyleCard(
              title: AppTexts.nextPlayerStandby(player.name),
              content: message,
              primaryButtonText: AppTexts.startTurnButton,
              onPrimaryPressed: onReady,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: AppColors.textOnDark,
                tooltip: AppTexts.goSettings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlayerColor(int index) {
    return AppColors.playerPalette[index % AppColors.playerPalette.length];
  }
}

class _BracketCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  const _BracketCornerPainter({
    required this.color,
    this.strokeWidth = 3,
    this.cornerLength = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BracketCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength;
  }
}
