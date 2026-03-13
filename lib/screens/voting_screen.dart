import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/common_app_bar.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class VotingScreen extends StatelessWidget {
  final List<Player> players;
  final int currentVoterIndex;
  final Map<int, int> currentAllocation;
  final VoidCallback onHomePressed;
  final void Function(int index, int newVal) onAllocationChanged;
  final void Function(int index) onIncrement;
  final void Function(int index) onDecrement;
  final VoidCallback submitVote;

  const VotingScreen({
    super.key,
    required this.players,
    required this.currentVoterIndex,
    required this.currentAllocation,
    required this.onHomePressed,
    required this.onAllocationChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.submitVote,
  });

  @override
  Widget build(BuildContext context) {
    final voter = players[currentVoterIndex];
    int usedBudget = currentAllocation.values.fold(0, (sum, amount) => sum + amount);
    int remainingBudget = 100 - usedBudget;
    bool isComplete = usedBudget == 100;

    return Scaffold(
      appBar: CommonAppBar(
        title: "",
        onHomePressed: onHomePressed,
        showHelp: true,
      ),
      body: Column(
        children: [
          // --- ヘッダー ---
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 12
            ),
            width: 400,
            decoration: BoxDecoration(
              color: AppColors.accent,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${voter.name}さん${AppTexts.nextVoter}",
                  style: AppTextStyles.labelBold,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _budgetChip(
                      "のこり",
                      remainingBudget,
                      remainingBudget < 0
                          ? AppColors.actionDanger
                          : AppColors.textAccentStrong,
                    ),
                    _budgetChip("さいだい", 100, AppColors.textPrimary),
                  ],
                ),
              ],
            ),
          ),
          // --- 投票カード一覧 ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                if (index == currentVoterIndex) return const SizedBox.shrink();

                int currentAmount = currentAllocation[index] ?? 0;
                int maxAllowable = (currentAmount + remainingBudget).clamp(0, 100);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 研究タイトル（大）
                        Text(
                          p.researchTitle,
                          style: AppTextStyles.valueDisplayLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppTexts.researcherName(p.name),
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: 10),
                        // カスタムバー
                        BudgetBar(
                          value: currentAmount,
                          maxAllowable: maxAllowable,
                          onChanged: (val) => onAllocationChanged(index, val),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppTexts.budgetAmount(currentAmount),
                          style: AppTextStyles.amountAccent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // --- 確定ボタン ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isComplete
                        ? AppColors.actionDanger
                        : AppColors.actionDisabled,
                    foregroundColor: AppColors.textOnDark,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isComplete ? submitVote : null,
                  child: const Text(
                    AppTexts.decideBudget,
                    style: AppTextStyles.buttonMediumBold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetChip(String label, int amount, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        const SizedBox(height: 2),
        Text(
          "${amount}万円",
          style: AppTextStyles.valueLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// ドラッグ可能な予算配分バー
class BudgetBar extends StatefulWidget {
  final int value;
  final int maxAllowable;
  final void Function(int) onChanged;

  const BudgetBar({
    super.key,
    required this.value,
    required this.maxAllowable,
    required this.onChanged,
  });

  @override
  State<BudgetBar> createState() => _BudgetBarState();
}

class _BudgetBarState extends State<BudgetBar> {
  double _barWidth = 0;

  void _handleDrag(double localX) {
    if (_barWidth <= 0) return;
    final ratio = (localX / _barWidth).clamp(0.0, 1.0);
    final newVal = (ratio * 100).round().clamp(0, widget.maxAllowable);
    widget.onChanged(newVal);
  }

  @override
  Widget build(BuildContext context) {
    // 0〜100スケールで表示、maxAllowableを上限にドラッグ
    final fillRatio = (widget.value / 100).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        _barWidth = constraints.maxWidth;
        final thumbLeft = (_barWidth * fillRatio - 12).clamp(0.0, _barWidth - 24);

        return GestureDetector(
          onHorizontalDragUpdate: (d) => _handleDrag(d.localPosition.dx),
          onTapDown: (d) => _handleDrag(d.localPosition.dx),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // トラック（背景）
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAccent.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // フィル（塗り）
                FractionallySizedBox(
                  widthFactor: fillRatio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.actionPrimary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // サム（ドラッグハンドル）
                Positioned(
                  left: thumbLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.actionPrimary,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
