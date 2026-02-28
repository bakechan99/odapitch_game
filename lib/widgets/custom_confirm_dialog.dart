import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_banner_ad.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;
  final IconData icon;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = AppTexts.ok,
    this.cancelText = AppTexts.cancel,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.dialogSurface,
      elevation: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上部アイコン
            Icon(icon, size: 48, color: AppColors.dialogIcon),
            const SizedBox(height: 20),
            
            // タイトル
            Text(
              title,
              style: AppTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 本文
            Text(
              content,
              style: AppTextStyles.dialogBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // ボタンエリア
            Row(
              children: [
                // キャンセルボタン
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.dialogCancelText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: AppColors.dialogBorder),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: AppTextStyles.buttonLabelBold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // OKボタン
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dialogConfirmBgStrong, // 濃いグレー
                      foregroundColor: AppColors.textOnDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: AppTextStyles.buttonLabelBold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 広告バナー
            const SizedBox(
              height: 60, // 広告の高さ分のスペースを確保
              child: CustomBannerAd(),
            ),
          ],
        ),
      ),
    );
  }
}