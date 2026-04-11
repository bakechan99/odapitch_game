import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../models/player.dart';
import '../models/card_data.dart';
import '../models/placed_card.dart';
import '../widgets/common_app_bar.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ResultView extends StatelessWidget {
  final List<Player> players;
  final String odaiTheme;
  final Map<int, Map<int, int>> voteMatrix;
  // AIの結果を受け取る
  final Map<int, Map<String, dynamic>> aiResults;
  // 全体の総評（一括評価で取得）
  final String? overallReview;
  final Color Function(int) getPlayerColor;
  final VoidCallback onHomePressed;

  const ResultView({
    super.key,
    required this.players,
    required this.odaiTheme,
    required this.voteMatrix,
    required this.aiResults,
    this.overallReview,
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

    // バーの最大値 = 全プレイヤー中の最高得点の1.1倍（切り上げ）
    // results はソート済みなので先頭が最大値
    final int _maxResultTotal = results.isEmpty ? 0 : (results[0]['total'] as int);
    final int barMax = _maxResultTotal > 0 ? (_maxResultTotal * 11 + 9) ~/ 10 : 1;

    return Scaffold(
      appBar: CommonAppBar(
        title: "",
        onHomePressed: onHomePressed,
      ),
      body:Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: results.length + 1, // +1 はヘッダー（画像＋テーマ）分
              padding: EdgeInsets.zero, // 画像をフルwidthにするためpadding無し
              itemBuilder: (context, index) {
                // index 0 はヘッダー（画像＋テーマ名＋総評）
                if (index == 0) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/GND_showResults.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          AppTexts.odaitheme(odaiTheme),
                          style: AppTextStyles.headingPrimaryLarge.copyWith(
                            fontSize: 28,
                          ),
                        ),
                      ),
                      // AI総評ボックス（overallReview がある場合のみ表示）
                      if (overallReview != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfacePanel,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.sectionTitle,
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    overallReview!,
                                    style: const TextStyle(fontSize: 14, height: 1.6),
                                  ),
                                ),
                                Positioned(
                                  top: -2,
                                  left: 16,
                                  child: Container(
                                    color: AppColors.surfacePanel,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      AppTexts.aiOverallReviewLabel,
                                      style: AppTextStyles.headingPrimaryLarge.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }
                final data = results[index - 1]; // ヘッダー分ずらす
                final player = data['player'] as Player;
                final int baseTotal = data['baseTotal'] as int;
                final int total = data['total'] as int;
                final Map<int, int> breakdown = data['breakdown'] as Map<int, int>;
                
                // 💡 単数形の aiData として取り出す！
                final Map<String, dynamic>? playerAiData = data['aiData'] as Map<String, dynamic>?;

                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (index == 1) // index 1 が1位（index 0 はヘッダー）
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset(
                                  'assets/images/winners_crown_icon.png',
                                  fit: BoxFit.contain,
                                ),
                              )
                            else
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black87,
                                    width: 1.2,
                                  ),
                                  color: AppColors.surface, // 背景色（不要なら削除）
                                ),
                                child: Text(
                                  '$index', // index 1 → 1位, index 2 → 2位...
                                  style: AppTextStyles.headingPrimaryMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 150,
                              child:Text(
                                player.name, 
                                style: AppTextStyles.playerName.copyWith(
                                  fontSize: 24,
                                )
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: ' $total ',
                                        style: AppTextStyles.headingPrimaryLarge.copyWith(
                                          fontSize: 32
                                        ),
                                      ),
                                      TextSpan(
                                        text: '万円',
                                        style: AppTextStyles.headingPrimaryLarge.copyWith(
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: AutoSizeText(
                            player.researchTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headingPrimaryLarge.copyWith(
                              fontSize: 24,
                            ),
                            maxLines: 3,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: playerAiData != null
                            ? Text.rich(
                                TextSpan(
                                  style: AppTextStyles.headingPrimaryMedium.copyWith(
                                    fontSize: 24,
                                  ),
                                  children: [
                                    TextSpan(text: AppTexts.budgetAmount(baseTotal)),
                                    TextSpan(text: AppTexts.aiScoreLabel(playerAiData['score'] ?? 0)),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                AppTexts.budgetAmount(baseTotal),
                                style: AppTextStyles.headingPrimaryMedium.copyWith(
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.titleButtonBorder,
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 20,
                            color: AppColors.actionDisabled,
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
                                                child: amount >= 10 ? Text(AppTexts.amountOnly(amount), style: AppTextStyles.amountTinyOnDark) : null,
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                Expanded(
                                  flex: barMax - total, 
                                  child: const SizedBox.shrink()
                                ),
                              ],
                            ),
                          ),
                        ),  // ClipRRect
                        ),  // border Container
                        const SizedBox(height: 16),
                        
                        // 🌟 ここからAIの採点結果表示UI！
                        // Stack で「枠線上にラベルを重ねる」InputDecoration風のデザイン
                        if (playerAiData != null)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // 枠線付きContainer（上マージンでラベル分のスペースを確保）
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.sectionTitle),
                                    ),
                                    child: Text(
                                      AppTexts.aiFeedbackLabel(
                                        (playerAiData['feedback'] ?? AppTexts.aiNoFeedback).toString()
                                      ),
                                      style: const TextStyle(fontSize: 14, height: 1.4),
                                    ),
                                  ),
                                  // 枠線に重なるラベル（背景色で枠線を隠してフローティング表示）
                                  Positioned(
                                    top: -12,
                                    left: 12,                                    child: Container(
                                      color: AppColors.surface,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            AppTexts.aiEvaluationPrefix,
                                            style: AppTextStyles.headingPrimaryLarge.copyWith(
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            AppTexts.aiScoreLabel(playerAiData['score'] ?? 0),
                                            style: AppTextStyles.headingPrimaryLarge.copyWith(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, 
                  blurRadius: 4, 
                  offset: Offset(0, 2),
                  
                ),
              ],
            ),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  backgroundColor: AppColors.themePrimaryLight,
                  shadowColor: AppColors.shadowBase,
                  elevation: 10,
                ),
                onPressed: onHomePressed,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppTexts.backToTitle,
                    style: AppTextStyles.headingPrimaryLarge.copyWith(
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
    );
  }
}

/// 結果画面用カードWidget（選択段をハイライト表示）
class ResultCardWidget extends StatelessWidget {
  final CardData card;
  final int? selectedSection; // null = 使っていないカード

  const ResultCardWidget({super.key, required this.card, this.selectedSection});

  @override
  Widget build(BuildContext context) {
    Widget section(String text, int idx) {
      final bool isSelected = idx == selectedSection;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectionHighlight : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: AppTextStyles.cardHandText.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedSection != null ? AppColors.borderLight : AppColors.borderLight,
          width: selectedSection != null ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          section(card.top, 0),
          Divider(height: 1, color: AppColors.divider),
          section(card.middle, 1),
          Divider(height: 1, color: AppColors.divider),
          section(card.bottom, 2),
        ],
      ),
    );
  }
}
