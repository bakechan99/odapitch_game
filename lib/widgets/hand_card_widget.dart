import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 手札に表示するカードWidget。
/// Draggable のラップは呼び出し元で行う。
class HandCardWidget extends StatelessWidget {
  final CardData card;

  const HandCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    const textStyle = AppTextStyles.cardHandText;
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMuted.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(card.top, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: AppColors.divider),
          Text(card.middle, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: AppColors.divider),
          Text(card.bottom, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
