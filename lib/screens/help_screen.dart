import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_text_styles.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themePrimary,
      appBar: AppBar(
        title: const Text(""),
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
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [      
          
                  _HelpStepCard(
                    stepNumber: '1',
                    title: AppTexts.helpSetupOverview,
                    description: AppTexts.helpPlayerCount,
                    imagePath: 'assets/images/image_help_1.png',
                  ),
                  const SizedBox(height: 24),
                  _HelpStepCard(
                    stepNumber: '2',
                    title: AppTexts.helpTimeSettings,
                    description: "",
                    imagePath: 'assets/images/image_help_1.png',
                  ),
                  const SizedBox(height: 24),
                  _HelpStepCard(
                    stepNumber: '3',
                    title: AppTexts.helpCardPreset,
                    description: "",
                    imagePath: 'assets/images/image_help_1.png',
                  ),
                  const SizedBox(height: 24),
                  _HelpStepCard(
                    stepNumber: '4',
                    title: AppTexts.helpPlayerNames,
                    description: "",
                    imagePath: 'assets/images/image_help_1.png',
                  ),
                  const SizedBox(height: 24),
                  _HelpStepCard(
                    stepNumber: '5',
                    title: AppTexts.helpStartGame,
                    description: "",
                    imagePath: 'assets/images/image_help_1.png',
                  ),
                ],
              ),
            )
          )
        ),
      ),
    );
  }
}

class _HelpStepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final String imagePath;

  const _HelpStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.shadowBase,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppTexts.helpTitle,
            style: AppTextStyles.titleButton.copyWith(
              fontSize: 40,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ), 
          Row(
            children: [
              const SizedBox(width: 30),
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black87,
                    width: 1.2,
                  ),
                  color: AppColors.surface,
                ),
                child: Text(
                  stepNumber,
                  style: AppTextStyles.headingPrimaryMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.dialogBody,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      description,
                      style: AppTextStyles.dialogBody.copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Image.asset(imagePath),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
