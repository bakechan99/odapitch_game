import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../constants/texts.dart';

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
    final activeTextStyle = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87);
    final inactiveTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.grey);
    final activeLabelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
    final inactiveLabelStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.presentationTitle(player.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: onHomePressed,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
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
                          color: Colors.orange,
                          onPressed: toggleTimer,
                        )
                      else
                        const SizedBox(height: 56 + 16),
                    ],
                  ),
                  Container(width: 1, height: 100, color: Colors.grey[300]),
                  Column(
                    children: [
                      Text("質疑応答", style: !isPresentationMode ? activeLabelStyle : inactiveLabelStyle),
                      Text(AppTexts.secondsUnit(qaTimeLeft), style: !isPresentationMode ? activeTextStyle : inactiveTextStyle),
                      const SizedBox(height: 5),
                      if (!isPresentationMode)
                        IconButton(
                          icon: Icon(isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          iconSize: 56,
                          color: Colors.blue,
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
            const Text("【研究課題】", style: TextStyle(fontSize: 20, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  player.researchTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: proceedToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPresentationMode ? Colors.orange : Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(isPresentationMode ? "質疑応答へ進む" : "終了して次の人へ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
