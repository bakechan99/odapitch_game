import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_text_styles.dart';
import 'settings_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.helpTitle),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(AppTexts.helpSetupOverview, style: AppTextStyles.dialogBody),
            SizedBox(height: 16),
            Text(AppTexts.helpPlayerCount, style: AppTextStyles.dialogBody),
            SizedBox(height: 10),
            Text(AppTexts.helpTimeSettings, style: AppTextStyles.dialogBody),
            SizedBox(height: 10),
            Text(AppTexts.helpCardPreset, style: AppTextStyles.dialogBody),
            SizedBox(height: 10),
            Text(AppTexts.helpPlayerNames, style: AppTextStyles.dialogBody),
            SizedBox(height: 16),
            Text(AppTexts.helpStartGame, style: AppTextStyles.dialogBody),
          ],
        ),
      ),
    );
  }
}
