import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PassingStyleCard extends StatelessWidget {
  final String title;
  final String? content;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const PassingStyleCard({
    super.key,
    required this.title,
    this.content,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasSecondary = secondaryButtonText != null && onSecondaryPressed != null;

    return Container(
      width: 300,
      height: 300,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.headingSectionLarge,
              textAlign: TextAlign.center,
            ),
            if ((content ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                content!,
                style: AppTextStyles.headingPrimaryMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 40),
            if (hasSecondary)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryPressed,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonNo,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.titleButtonBorder
                        ),
                        shadowColor: AppColors.shadowBase,
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: AppTextStyles.buttonPrimaryBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryPressed,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColors.buttonYes,
                        foregroundColor: AppColors.textOnDark,
                        shadowColor: AppColors.shadowBase,
                        elevation: 10,
                      ),
                      child: Text(
                        primaryButtonText,
                        style: AppTextStyles.buttonPrimaryBold,
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: AppColors.buttonYes,
                  foregroundColor: AppColors.textOnDark,
                  shadowColor: AppColors.shadowBase,
                  elevation: 10,
                ),
                child: Text(
                  primaryButtonText,
                  style: AppTextStyles.buttonPrimaryBold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
