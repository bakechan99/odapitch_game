import 'dart:async';
import 'dart:math' as math;
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
import '../widgets/custom_banner_ad.dart';
import '../data/local_db.dart';
import '../utils/audio_manager.dart';

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

  final ScrollController _aiHorizontalScrollController = ScrollController();
  bool _historySaved = false;

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
      onTimeUp: _onTimeUp,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_controller.currentPhase == ScreenPhase.result && !_historySaved) {
      _historySaved = true;
      _saveHistory();
    }
  }

  Future<void> _saveHistory() async {
    final players = List.generate(widget.players.length, (i) {
      final player = widget.players[i];
      final aiData = _controller.aiResults[i];
      final feedback = aiData != null
          ? (aiData['feedback'] ?? AppTexts.aiNoFeedback).toString()
          : AppTexts.aiNoFeedback;
      return {
        'name': player.name,
        'title': player.researchTitle,
        'feedback': feedback,
      };
    });
    await LocalDb.instance.saveHistory(
      odaiTheme: widget.odaiTheme,
      players: players,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
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

  Future<void> _onTimeUp(bool isPresentationMode) async {
    if (isPresentationMode) {
      await AudioManager.instance.playSingleBell();
    } else {
      await AudioManager.instance.playDoubleBell();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isFetchingAI) {
          return Scaffold(
            appBar: CommonAppBar(
              title: "",
              onHomePressed: _onHomePressed,
              backgroundColor: AppColors.themePrimaryLight,
            ),
            backgroundColor: AppColors.themePrimaryLight,
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          color: AppColors.themePrimaryDark,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'AI採点中...',
                        style: AppTextStyles.headingPrimaryLarge.copyWith(
                          fontSize: 48,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                          final int count = widget.players.length;
                          final double cardsWidth =
                              (count * 400) +
                              ((count > 0 ? count - 1 : 0) * 16);
                          final double horizontalPadding = 32;
                          final double trailingSpace = 100;
                          final double contentWidth =
                              cardsWidth + horizontalPadding + trailingSpace;
                          final double minScrollableWidth =
                              constraints.maxWidth + 120;
                          final double rowWidth = math.max(
                            contentWidth,
                            minScrollableWidth,
                          );

                          return PrimaryScrollController(
                            controller: _aiHorizontalScrollController,
                            child: Scrollbar(
                              controller: _aiHorizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              interactive: true,
                              child: SingleChildScrollView(
                                controller: _aiHorizontalScrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics(),
                                ),
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: SizedBox(
                                  width: rowWidth - horizontalPadding,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...List.generate(widget.players.length, (
                                        idx,
                                      ) {
                                        final p = widget.players[idx];
                                        final List<CardData> allCards = [
                                          ...p.hand,
                                          ...p.selectedCards.map(
                                            (pc) => pc.card,
                                          ),
                                        ];
                                        allCards.sort(
                                          (a, b) => a.id.compareTo(b.id),
                                        );

                                        return Container(
                                          width: 400,
                                          height: 600,
                                          margin: EdgeInsets.only(
                                            right:
                                                idx == widget.players.length - 1
                                                ? 0
                                                : 16,
                                          ),
                                          child: Card(
                                            color: AppColors.surfacePanel,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 200,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(height: 12),
                                                        Text(
                                                          "${p.name}さんの回答",
                                                          style: AppTextStyles
                                                              .headingPrimaryMedium
                                                              .copyWith(
                                                                fontSize: 20,
                                                              ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Expanded(
                                                          child: Center(
                                                            child: SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child: CustomPaint(
                                                                painter: _BracketCornerPainter(
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                  child: Text(
                                                                    p.researchTitle,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: AppTextStyles
                                                                        .headingPrimaryLarge
                                                                        .copyWith(
                                                                          fontSize:
                                                                              32,
                                                                          fontStyle:
                                                                              FontStyle.normal,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),

                                                  Wrap(
                                                    spacing: 24,
                                                    runSpacing: 16,
                                                    children: allCards.map((
                                                      cardData,
                                                    ) {
                                                      int? selectedSection;
                                                      for (final placedCard
                                                          in p.selectedCards) {
                                                        if (placedCard
                                                                .card
                                                                .id ==
                                                            cardData.id) {
                                                          selectedSection =
                                                              placedCard
                                                                  .selectedSection;
                                                          break;
                                                        }
                                                      }

                                                      return ResultCardWidget(
                                                        card: cardData,
                                                        selectedSection:
                                                            selectedSection,
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 100),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                    },
                  ),
                ),
              ],
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
              odaiTheme: widget.odaiTheme,
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
          const CustomBannerAd(),
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
