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
  });

  @override
  Widget build(BuildContext context) {
    final activeTextStyle = AppTextStyles.valueDisplayMedium;
    final inactiveTextStyle = AppTextStyles.valueDisplayMuted;
    final activeLabelStyle = AppTextStyles.labelField;
    final inactiveLabelStyle = AppTextStyles.labelMutedSmall;

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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("発表時間", style: isPresentationMode ? activeLabelStyle : inactiveLabelStyle),
                      Text(AppTexts.secondsUnit(timeLeft), style: isPresentationMode ? activeTextStyle : inactiveTextStyle),
                      const SizedBox(height: 5),
                      if (isPresentationMode)
                        IconButton(
                          icon: Icon(isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          iconSize: 56,
                          color: AppColors.actionAccent,
                          onPressed: toggleTimer,
                        )
                      else
                        const SizedBox(height: 56 + 16),
                    ],
                  ),
                  Container(width: 1, height: 100, color: AppColors.dividerStrong),
                  Column(
                    children: [
                      Text("質疑応答", style: !isPresentationMode ? activeLabelStyle : inactiveLabelStyle),
                      Text(AppTexts.secondsUnit(qaTimeLeft), style: !isPresentationMode ? activeTextStyle : inactiveTextStyle),
                      const SizedBox(height: 5),
                      if (!isPresentationMode)
                        IconButton(
                          icon: Icon(isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          iconSize: 56,
                          color: AppColors.actionPrimary,
                          onPressed: toggleTimer,
                        )
                      else
                        const SizedBox(height: 56 + 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("【研究課題】", style: AppTextStyles.headingSectionLarge),
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
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: proceedToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPresentationMode ? AppColors.actionAccent : AppColors.actionPrimary,
                  foregroundColor: AppColors.textOnDark,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(isPresentationMode ? "質疑応答へ進む" : "終了して次の人へ", style: AppTextStyles.buttonPrimaryBold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
