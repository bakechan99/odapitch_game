import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SettingStepperControl extends StatelessWidget {
  final String? label;
  final Widget valueChild;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final double sideSpacing;
  final double middleSpacing;

  const SettingStepperControl({
    super.key,
    this.label,
    required this.valueChild,
    this.onDecrement,
    this.onIncrement,
    this.sideSpacing = 20,
    this.middleSpacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (label != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Align(
            alignment: Alignment.center,
            child: Text(label!, style: AppTextStyles.labelField),
          ),
        ),
      );
      children.add(const SizedBox(height: 5));
    }

    children.add(
      Row(
        children: [
          SizedBox(width: sideSpacing),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.remove,
                size: 16,
                color: AppColors.textMuted,
              ),
              onPressed: onDecrement,
            ),
          ),
          SizedBox(width: middleSpacing),
          Expanded(
            child: Center(child: valueChild),
          ),
          SizedBox(width: middleSpacing),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.textMuted,
              ),
              onPressed: onIncrement,
            ),
          ),
          SizedBox(width: sideSpacing),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}