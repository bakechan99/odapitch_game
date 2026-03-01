import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'setting_stepper_control.dart';

class TimeSettingControl extends StatelessWidget {
  final String label;
  final int value;
  final TextStyle? style;
  final double valueWidthRatio;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const TimeSettingControl({
    super.key,
    required this.label,
    required this.value,
    this.style,
    this.valueWidthRatio = 0.5,
    required this.onDecrement,
    required this.onIncrement,
  });

  String _formatClock(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {

    return SettingStepperControl(
      label: label,
      onDecrement: onDecrement,
      onIncrement: onIncrement,
      valueChild: SizedBox(
        width: 300,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.textStrong, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatClock(value),
                maxLines: 1,
                softWrap: false,
                style: style ??
                    AppTextStyles.timeValue.copyWith(
                      fontSize: 40,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
