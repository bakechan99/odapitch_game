import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class DecorativeBand extends StatelessWidget {
  final bool showBadge;
  final IconData badgeIcon;
  final double bandHeight;

  const DecorativeBand({
    super.key,
    this.showBadge = false,
    this.badgeIcon = Icons.style,
    this.bandHeight = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: bandHeight,
          color: AppColors.actionPrimary.withValues(alpha: 0.35),
          alignment: Alignment.center,
          child: Container(
            height: 3,
            color: AppColors.actionPrimary,
          ),
        ),
        if (showBadge)
          Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  badgeIcon,
                  size: 22,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
