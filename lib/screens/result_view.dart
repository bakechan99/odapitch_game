import 'package:flutter/material.dart';
import '../models/player.dart';
import 'settings_screen.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ResultView extends StatelessWidget {
  final List<Player> players;
  final Map<int, Map<int, int>> voteMatrix;
  // AIの結果を受け取る
  final Map<int, Map<String, dynamic>> aiResults;
  final Color Function(int) getPlayerColor;
  final VoidCallback onHomePressed;

  const ResultView({
    super.key,
    required this.players,
    required this.voteMatrix,
    required this.aiResults, // AI用追加
    required this.getPlayerColor,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> results = [];
    for (int i = 0; i < players.length; i++) {
      // ① プレイヤーからの投票合計（基本予算）
      int baseTotal = 0;
      Map<int, int> breakdown = voteMatrix[i] ?? {};
      breakdown.forEach((_, amount) => baseTotal += amount);

      // ② AIの評価倍率を安全に取得（エラー時は1.0倍にする）
      double aiMultiplier = 1.0;
      if (aiResults[i] != null && aiResults[i]!['score'] != null) {
        // ※ '1' (int) が来ても '1.5' (double) が来ても絶対にエラーにならない最強の書き方
        aiMultiplier = (aiResults[i]!['score'] as num).toDouble();
      }

      // ③ 掛け算して最終金額を計算（.toInt() で小数点以下を切り捨てて整数にする）
      int finalTotal = (baseTotal * aiMultiplier).toInt();

      // ④ 画面で計算式を見せるために、素の金額（baseTotal）と倍率（aiMultiplier）も保存しておく
      results.add({
        'player': players[i], 
        'baseTotal': baseTotal,         // 素の投票額
        'aiMultiplier': aiMultiplier,   // AIの倍率
        'total': finalTotal,            // 掛け算後の最終額（これでソートする！）
        'breakdown': breakdown, 
        'aiData': aiResults[i]
      }); 
    }
    // 掛け算後の「total」を使って、獲得金額順にソート（変更なし）
    results.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    // List<Map<String, dynamic>> results = [];
    // for (int i = 0; i < players.length; i++) {
    //   int total = 0;
    //   Map<int, int> breakdown = voteMatrix[i] ?? {};
    //   breakdown.forEach((_, amount) => total += amount);
    //   // 💡 aiData というキー名で保存します
    //   results.add({'player': players[i], 'total': total, 'breakdown': breakdown, 'aiData': aiResults[i]}); 
    // }
    // // 獲得金額順にソート
    // results.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    final int maxPossibleTotal = players.length * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.resultTitle),
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
          const Padding(padding: EdgeInsets.all(20.0), child: Text(AppTexts.resultHeader, style: AppTextStyles.headingPrimaryLarge)),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final data = results[index];
                final player = data['player'] as Player;
                final int total = data['total'] as int;
                final Map<int, int> breakdown = data['breakdown'] as Map<int, int>;
                
                // 💡 単数形の aiData として取り出す！
                final Map<String, dynamic>? playerAiData = data['aiData'] as Map<String, dynamic>?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (index == 0) const Text("🥇 ", style: AppTextStyles.rankEmoji),
                            if (index == 1) const Text("🥈 ", style: AppTextStyles.rankEmoji),
                            if (index == 2) const Text("🥉 ", style: AppTextStyles.rankEmoji),
                            Text("${index + 1}位", style: AppTextStyles.headingPrimaryMedium),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player.name, style: AppTextStyles.playerName),
                                  Text(player.researchTitle, style: AppTextStyles.captionMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text("$total 万円", style: AppTextStyles.amountTotal),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 30,
                            color: AppColors.surfaceSubtle,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: total,
                                  child: total > 0
                                      ? Row(
                                          children: breakdown.entries.map((entry) {
                                            int voterIndex = entry.key;
                                            int amount = entry.value;
                                            if (amount == 0) return const SizedBox.shrink();
                                            return Expanded(
                                              flex: amount,
                                              child: Container(
                                                color: getPlayerColor(voterIndex),
                                                alignment: Alignment.center,
                                                child: amount >= 10 ? Text("$amount", style: AppTextStyles.amountTinyOnDark) : null,
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                Expanded(flex: maxPossibleTotal - total, child: const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 🌟 ここからAIの採点結果表示UI！
                        if (playerAiData != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.smart_toy, size: 20, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI評価: ${playerAiData['score'] ?? 0}点', 
                                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '講評: ${playerAiData['feedback'] ?? '評価なし'}', 
                                  style: const TextStyle(fontSize: 14, height: 1.4)
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.surfaceSubtle,
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: List.generate(players.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: getPlayerColor(index)),
                    const SizedBox(width: 4),
                    Text(players[index].name, style: AppTextStyles.caption),
                  ],
                );
              }),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  onPressed: onHomePressed,
                  child: const Text(AppTexts.backToTitle, style: AppTextStyles.buttonMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
