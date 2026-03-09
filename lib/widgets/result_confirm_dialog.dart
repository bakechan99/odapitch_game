import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ResultConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  const ResultConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = AppTexts.ok,
    this.cancelText = AppTexts.cancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.dialogSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.dialogTitle,
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: AppTextStyles.dialogBody,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.dialogCancelText,
          ),
          child: Text(cancelText, style: AppTextStyles.buttonLabelBold),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dialogConfirmBgStrong,
            foregroundColor: AppColors.textOnDark,
          ),
          child: Text(confirmText, style: AppTextStyles.buttonLabelBold),
        ),
      ],
    );
  }
}
