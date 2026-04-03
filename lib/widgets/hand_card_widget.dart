import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 手札に表示するカードWidget。
/// Draggable のラップは呼び出し元で行う。
class HandCardWidget extends StatelessWidget {
  final CardData card;
  final double width;
  final double height;

  const HandCardWidget({
    super.key,
    required this.card,
    this.width = 100,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    // カード幅に比例したフォントサイズ（基準: width=100でfontSize=12）
    final double fontSize = AppTextStyles.cardHandText.fontSize! * (width / 100);
    final textStyle = AppTextStyles.cardHandText.copyWith(fontSize: fontSize);

    return Container(
      width: width,
      height: height,
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
          AutoSizeText(card.top, style: textStyle, textAlign: TextAlign.center, maxLines: 1, minFontSize: 8, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: AppColors.divider),
          AutoSizeText(card.middle, style: textStyle, textAlign: TextAlign.center, maxLines: 1, minFontSize: 8, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: AppColors.divider),
          AutoSizeText(card.bottom, style: textStyle, textAlign: TextAlign.center, maxLines: 1, minFontSize: 8, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
