// lib/widgets/fancy_button.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class FancyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  const FancyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.fancyButtonDefault, // デフォルト色
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // ボタンが無効(null)のときはグレーにする
    final isEnabled = onPressed != null;
    final displayColor = isEnabled ? color : AppColors.fancyButtonDisabled;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        // グラデーション（指定色から少し明るい色へ）
        gradient: isEnabled
            ? LinearGradient(
                colors: [displayColor, displayColor.withOpacity(0.7)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              )
            : LinearGradient(colors: [AppColors.fancyButtonDisabled, AppColors.fancyButtonDisabledLight]),
        borderRadius: BorderRadius.circular(30), // 丸い角
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: displayColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4), // 下に影
                ),
              ]
            : [],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textOnDark, size: 28),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: AppTextStyles.fancyButtonLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}