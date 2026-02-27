import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../constants/texts.dart';
import '../widgets/custom_confirm_dialog.dart';
import 'settings_screen.dart';
import 'presentation_screen.dart';
import 'voting_screen.dart';
import 'result_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../features/game_session/application/result_session_controller.dart';

import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;
  const ResultScreen({super.key, required this.players, required this.settings});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ResultSessionController _controller;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = ResultSessionController(
      players: widget.players,
      presentationTimeSec: widget.settings.presentationTimeSec,
      qaTimeSec: widget.settings.qaTimeSec,
      titleScorer: ApiService.getTitleScore,
      onTimeUp: _playSound,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _showConfirmDialog({required String title, String? content, required VoidCallback onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content ?? "",
        onConfirm: onConfirm,
        cancelText: AppTexts.cancel, 
        confirmText: AppTexts.ok, 
      ),
    );
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isFetchingAI) {
          return Scaffold(
            backgroundColor: AppColors.surfacePanel,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: AppColors.actionAccent),
                  SizedBox(height: 20),
                  Text(
                    'AIが全員のタイトルを厳正に審査中...',
                    style: AppTextStyles.headingOnDarkLarge,
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
              onReady: () => _showConfirmDialog(
                title: AppTexts.presentationStartTitle,
                content: AppTexts.presentationTimeMsg(widget.settings.presentationTimeSec),
                onConfirm: _controller.startPresentation,
              ),
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
              voteMatrix: _controller.voteMatrix,
              aiResults: _controller.aiResults,
              getPlayerColor: _getPlayerColor,
              onHomePressed: _onHomePressed,
            );
        }
      },
    );
  }

  Widget _buildStandbyScreen({required Player player, required String message, required VoidCallback onReady}) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
             decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppTexts.nextPlayerStandby(player.name), style: AppTextStyles.headingOnDarkLarge),
                const SizedBox(height: 10),
                Text(message, style: AppTextStyles.bodyOnDarkMedium),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onReady,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: const Text(AppTexts.startVoteButton, style: AppTextStyles.buttonPrimary),
                ),
              ],
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
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
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