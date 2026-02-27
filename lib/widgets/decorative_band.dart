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
    this.bandHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    const badgeSize = 80.0;
    final badgeTop = -(badgeSize - bandHeight);

    return SizedBox(
      width: double.infinity,
      height: bandHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AppColors.actionPrimary),
          ),
          if (showBadge)
            Positioned(
              top: badgeTop,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
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
      ),
    );
  }
}
