import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import 'settings_screen.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PresentationScreen extends StatelessWidget {
  final Player player;
  final bool isPresentationMode;
  final bool isTimerRunning;
  final int timeLeft;
  final int qaTimeLeft;
  final GameSettings settings;
  final VoidCallback onHomePressed;
  final VoidCallback toggleTimer;
  final VoidCallback proceedToNextStep;
  final VoidCallback onResetTimer;

  const PresentationScreen({
    super.key,
    required this.player,
    required this.isPresentationMode,
    required this.isTimerRunning,
    required this.timeLeft,
    required this.qaTimeLeft,
    required this.settings,
    required this.onHomePressed,
    required this.toggleTimer,
    required this.proceedToNextStep,
    required this.onResetTimer,
  });

  @override
  Widget build(BuildContext context) {
    final int activeTime = isPresentationMode ? timeLeft : qaTimeLeft;
    final String timerLabel = isPresentationMode
        ? AppTexts.presentationTimerLabel
        : AppTexts.qaTimerLabel;
    final Color timerColor = isPresentationMode
        ? AppColors.actionAccent
        : AppColors.actionPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.presentationTitle(player.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: onHomePressed,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppTexts.goSettings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- タイマーカード ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(timerLabel, style: AppTextStyles.labelMutedSmall),
                  const SizedBox(height: 8),
                  Text(
                    AppTexts.timerFormat(activeTime),
                    style: AppTextStyles.timeValue.copyWith(
                      fontSize: 64,
                      color: timerColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // リセットボタン
                      IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 36,
                        color: AppColors.textMuted,
                        onPressed: onResetTimer,
                        tooltip: "リセット",
                      ),
                      const SizedBox(width: 24),
                      // 再生/一時停止ボタン
                      IconButton(
                        icon: Icon(
                          isTimerRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                        ),
                        iconSize: 56,
                        color: timerColor,
                        onPressed: toggleTimer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(AppTexts.madeTitleHeader, style: AppTextStyles.headingSectionLarge),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  player.researchTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.valueDisplayLarge,
                ),
              ),
            ),
            // --- バナー ---
            GestureDetector(
              onTap: proceedToNextStep,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: timerColor.withOpacity(0.4), width: 1.5),
                ),
                child: Text(
                  isPresentationMode ? AppTexts.goFeedback : AppTexts.goToQa,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.buttonPrimaryBold.copyWith(color: timerColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
