import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../models/placed_card.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// フィールドに配置済みのカードWidget。
/// タップでセクション（上・中・下）を選択できる。
class PlacedCardWidget extends StatelessWidget {
  final PlacedCard placedCard;

  /// セクションがタップされたときのコールバック（0=上, 1=中, 2=下）。
  /// null の場合はタップ非活性（drag feedback などで使用）。
  final Function(int)? onTapSection;
  final double width;
  final double height;

  const PlacedCardWidget({
    super.key,
    required this.placedCard,
    this.onTapSection,
    this.width = 110,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    // カード幅に比例したフォントサイズ（基準: width=110でselected=16, unselected=12）
    final double selectedFontSize = AppTextStyles.cardTextSelected.fontSize! * (width / 110);
    final double unselectedFontSize = AppTextStyles.cardTextUnselected.fontSize! * (width / 110);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderAccent, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Expanded(child: _buildSection(placedCard.card.top, placedCard.selectedSection == 0, () => onTapSection?.call(0), selectedFontSize, unselectedFontSize)),
          const Divider(height: 1),
          Expanded(child: _buildSection(placedCard.card.middle, placedCard.selectedSection == 1, () => onTapSection?.call(1), selectedFontSize, unselectedFontSize)),
          const Divider(height: 1),
          Expanded(child: _buildSection(placedCard.card.bottom, placedCard.selectedSection == 2, () => onTapSection?.call(2), selectedFontSize, unselectedFontSize)),
        ],
      ),
    );
  }

  Widget _buildSection(String text, bool isSelected, VoidCallback onTap, double selectedFontSize, double unselectedFontSize) {
    final double fontSize = isSelected ? selectedFontSize : unselectedFontSize;
    final style = (isSelected ? AppTextStyles.cardTextSelected : AppTextStyles.cardTextUnselected).copyWith(fontSize: fontSize);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: isSelected ? AppColors.selectionHighlight : AppColors.transparent,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AutoSizeText(
          text,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 2,
          minFontSize: 8,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
