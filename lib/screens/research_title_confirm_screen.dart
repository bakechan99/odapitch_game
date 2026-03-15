import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/texts.dart';

class ResearchTitleConfirmScreen extends StatelessWidget {
  final String content;

  const ResearchTitleConfirmScreen({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.surfaceTheme),
          Center(
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowBase,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      AppTexts.confirmTitle,
                      style: AppTextStyles.headingSection.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: AppTextStyles.headingPrimaryLarge.copyWith(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.titleButtonBorder,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: AppColors.buttonNo,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 5,
                            ),
                            child: const Text(
                              AppTexts.cancel,
                              style: AppTextStyles.buttonPrimaryBold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: AppColors.buttonYes,
                              foregroundColor: AppColors.textOnDark,
                              elevation: 5,
                            ),
                            child: const Text(
                              AppTexts.ok,
                              style: AppTextStyles.buttonPrimaryBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
