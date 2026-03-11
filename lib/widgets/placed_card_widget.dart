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

  const PlacedCardWidget({
    super.key,
    required this.placedCard,
    this.onTapSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 140,
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
          Expanded(child: _buildSection(placedCard.card.top, placedCard.selectedSection == 0, () => onTapSection?.call(0))),
          const Divider(height: 1),
          Expanded(child: _buildSection(placedCard.card.middle, placedCard.selectedSection == 1, () => onTapSection?.call(1))),
          const Divider(height: 1),
          Expanded(child: _buildSection(placedCard.card.bottom, placedCard.selectedSection == 2, () => onTapSection?.call(2))),
        ],
      ),
    );
  }

  Widget _buildSection(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: isSelected ? AppColors.selectionHighlight : AppColors.transparent,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: isSelected ? AppTextStyles.cardTextSelected : AppTextStyles.cardTextUnselected,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
