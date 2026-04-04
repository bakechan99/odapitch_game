import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// ON/OFFトグルボタン。[onLabel]・[offLabel] でそれぞれのテキストを指定できる。
class OnOffToggleButton extends StatelessWidget {
  const OnOffToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.onLabel = 'ON',
    this.offLabel = 'OFF',
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 84,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? AppColors.highlights : AppColors.iconMuted,
          border: Border.all(
            color: AppColors.textStrong,
            width: 1.6,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 66,
          height: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textOnDark,
              width: 1.4,
            ),
          ),
          child: Text(
            value ? onLabel : offLabel,
            style: AppTextStyles.headingSection.copyWith(
              fontSize: 32,
              color: AppColors.textOnDark,
            ),
          ),
        ),
      ),
    );
  }
}
