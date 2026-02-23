import 'package:flutter/material.dart';
import '../models/player.dart';
import 'settings_screen.dart';
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
      appBar: AppBar(
        title: Text(AppTexts.votingTitle(voter.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: onHomePressed),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppTexts.goSettings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfacePanel,
            width: double.infinity,
            child: Column(
              children: [
                const Text("最も予算を与えたい研究に配分してください", style: AppTextStyles.labelBold),
                const SizedBox(height: 10),
                Text(
                  "残り予算: $remainingBudget 万円 / 100 万円",
                  style: AppTextStyles.valueLarge.copyWith(
                    color: remainingBudget < 0 ? AppColors.actionDanger : AppColors.textAccentStrong,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                if (index == currentVoterIndex) return const SizedBox.shrink();

                int currentAmount = currentAllocation[index] ?? 0;
                //double maxVal = (currentAmount + remainingBudget).toDouble();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppTexts.researchTitle(p.researchTitle), style: AppTextStyles.labelField),
                        Text("研究者: ${p.name}", style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("$currentAmount 万円", style: AppTextStyles.amountAccent),
                            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => onDecrement(index)),
                            Expanded(
                              child: Slider(
                                value: currentAmount.toDouble(),
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: "$currentAmount",
                                onChanged: (val) {
                                  int newVal = val.toInt();
                                  if (newVal > currentAmount + remainingBudget) {
                                    newVal = currentAmount + remainingBudget;
                                  }
                                  onAllocationChanged(index, newVal);
                                },
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onIncrement(index)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isComplete ? AppColors.actionDanger : AppColors.actionDisabled, foregroundColor: AppColors.textOnDark, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: isComplete ? submitVote : null,
                  child: const Text("投票を確定する", style: AppTextStyles.buttonMediumBold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
