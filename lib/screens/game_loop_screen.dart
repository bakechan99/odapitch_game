import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../models/player.dart';
import '../models/placed_card.dart';
import '../models/game_settings.dart'; // 設定モデル
import 'result_screen.dart';
import 'settings_screen.dart';
import '../constants/texts.dart'; // 追加
import '../widgets/custom_confirm_dialog.dart'; // 追加
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class GameLoopScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings; // 設定を受け取る
  const GameLoopScreen({super.key, required this.players, required this.settings});

  @override
  State<GameLoopScreen> createState() => _GameLoopScreenState();
}

class _GameLoopScreenState extends State<GameLoopScreen> {
  int currentPlayerIndex = 0;
  bool isPassing = true;

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _nextPlayer() {
    // ポップアップで確認
    Player player = widget.players[currentPlayerIndex];
    _showConfirmDialog(
      title: AppTexts.confirmTitle,
      content: "${AppTexts.confirmResearchTitle}\n\n「${player.researchTitle}」", // 研究タイトルを表示
      onConfirm: () {
        if (currentPlayerIndex < widget.players.length - 1) {
          setState(() {
            currentPlayerIndex++;
            isPassing = true;
          });
        } else {
          // 全員終了 -> 結果発表画面へ（設定も渡す）
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                players: widget.players,
                settings: widget.settings,
              ),
            ),
          );
        }
      },
    );
  }

  // --- 共通確認ダイアログ ---
  Future<void> _showConfirmDialog({required String title, required String content, required VoidCallback onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        cancelText: AppTexts.cancel,
      ),
    );
  }

  // --- 画面1: 順番確認（スマホ受渡）画面 ---
  Widget _buildPassingScreen(Player player) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/title_bg_2.png'), fit: BoxFit.cover),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppTexts.nextPlayerMessage(player.name), 
                  style: AppTextStyles.headingOnDarkMedium),
                const SizedBox(height: 30),
                const Icon(Icons.phone_android, size: 100, color: AppColors.textOnDark),
                const SizedBox(height: 30),
                Text(AppTexts.passSmartphoneMessage, style: AppTextStyles.bodyOnDarkSmall),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmDialog(
                      title: AppTexts.confirmTitle,
                      content: AppTexts.areYouReady(player.name), 
                      onConfirm: () => setState(() => isPassing = false)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: AppColors.actionAccent,
                    foregroundColor: AppColors.textOnDark,
                  ),
                  child: const Text(AppTexts.startTurnButton, style: AppTextStyles.buttonPrimaryBold),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: AppColors.textOnDark,
                tooltip: AppTexts.goSettings,
                onPressed: _openSettings,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 画面2: メインゲーム画面 ---
  Widget _buildGameScreen(Player player) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.turnTitle(player.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            _showConfirmDialog(
              title: AppTexts.checkPop,
              content: AppTexts.cautionBackHome,
              onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppTexts.goSettings,
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 上部エリア: 作成エリア (フィールド) ---
          Expanded(
            flex: 1, // 1:1 の比率で分割
            child: DragTarget<CardData>(
              // 背景全体へのドロップ判定（末尾追加）
              onWillAccept: (data) => data != null,
              onAccept: (card) {
                // 背景にドロップされた場合はリストの末尾に追加
                _onDropToField(player, card, player.selectedCards.length);
              },
              builder: (context, candidates, rejected) {
                return Container(
                  width: double.infinity,
                  color: AppColors.surfaceMuted, // 背景色
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダーテキスト
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          AppTexts.researchAreaHeader,
                          style: AppTextStyles.labelAccentBold,
                        ),
                      ),
                      // 横スクロールエリア
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true, // スクロールバーを常に表示
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center, // 縦方向中央揃え
                              children: [
                                // カード配置エリア (Rowの中身)
                                ..._buildFieldItems(player),
                                
                                // 領域が空の時のメッセージ（カードがない場合のみ表示）
                                if (player.selectedCards.isEmpty)
                                  Container(
                                    width: 200,
                                    height: 140,
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppTexts.handEmpty,
                                      style: AppTextStyles.bodyPlaceholder,
                                    ),
                                  ),
                                  
                                // 末尾に余白を持たせてドロップしやすくする
                                const SizedBox(width: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- 下部エリア: 手札エリア ---
          Expanded(
            flex: 1, // 1:1 の比率で分割
            child: DragTarget<CardData>(
              onWillAccept: (data) => data != null,
              onAccept: (card) {
                _returnToHand(player, card);
              },
              builder: (context, candidates, rejected) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBase.withOpacity(0.15), // 影を少し濃く
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 手札エリアのヘッダー
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(AppTexts.hands, style: AppTextStyles.labelMutedBold),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.actionPrimary,
                                foregroundColor: AppColors.textOnDark,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: player.selectedCards.isEmpty ? null : _nextPlayer,
                              child: const Text(AppTexts.decideButton, style: AppTextStyles.buttonSmall),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1), // 区切り線
                      
                      // 横スクロールリスト
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            itemCount: player.hand.length,
                            itemBuilder: (context, index) {
                              final card = player.hand[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Center( // 縦方向中央揃え
                                  child: Draggable<CardData>(
                                    data: card,
                                    feedback: Material(
                                      color: AppColors.transparent,
                                      child: Opacity(opacity: 0.8, child: _buildHandCardContent(card)),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _buildHandCardContent(card),
                                    ),
                                    child: _buildHandCardContent(card),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- フィールドアイテムの構築 (Row Children) ---
  List<Widget> _buildFieldItems(Player player) {
    List<Widget> items = [];
    
    // カードの間に挿入ポイント(Gap)を作る
    for (int i = 0; i < player.selectedCards.length; i++) {
      // 1. 挿入ポイント (Gap)
      items.add(_buildGapTarget(player, i));
      
      // 2. 配置済みカード
      final placedCard = player.selectedCards[i];
      items.add(
        Draggable<CardData>(
          data: placedCard.card,
          feedback: Material(
            color: AppColors.transparent,
            child: Opacity(
              opacity: 0.8,
              child: _buildPlacedCardContent(placedCard, null), // feedback用
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildPlacedCardContent(placedCard, null),
          ),
          child: _buildPlacedCardContent(
            placedCard,
            (sectionIndex) {
              setState(() {
                placedCard.selectedSection = sectionIndex;
              });
            },
          ),
        ),
      );
    }
    // 最後の挿入ポイント
    items.add(_buildGapTarget(player, player.selectedCards.length));

    return items;
  }

  // --- 隙間 (挿入ポイント) のターゲット ---
  Widget _buildGapTarget(Player player, int insertIndex) {
    return DragTarget<CardData>(
      onWillAccept: (data) => data != null,
      onAccept: (card) {
        _onDropToField(player, card, insertIndex);
      },
      builder: (context, candidates, rejected) {
        // ドラッグ中のアイテムが上に来たらカーソルを表示
        if (candidates.isNotEmpty) {
          return Container(
            // 判定エリアが小さくなるとちらつき（Enter/Leaveのループ）が発生するため、
            // 透明なコンテナで幅を確保しつつ、中央にカーソル線を描画します。
            width: 40, 
            height: 140,
            color: AppColors.transparent,
            child: Center(
              child: Container(
                width: 4, // 細い線
                height: 100, // カードより少し小さめ
                margin: const EdgeInsets.symmetric(horizontal: 4), // 左右のマージン
                decoration: BoxDecoration(
                  color: AppColors.actionPrimary, // カーソル色
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }
        // 通常時は目に見えないが判定はある領域
        return Container(
          width: 30, // ヒット判定幅
          height: 140,
          color: AppColors.transparent,
        );
      },
    );
  }

  // --- ロジック: フィールドへのドロップ処理 ---
  void _onDropToField(Player player, CardData card, int insertIndex) {
    setState(() {
      // 1. 手札から来た場合
      if (player.hand.contains(card)) {
        player.hand.remove(card);
        // 新規配置 (デフォルトは中段選択など)
        player.selectedCards.insert(insertIndex, PlacedCard(card: card, selectedSection: 1));
      } 
      // 2. フィールド内の移動の場合
      else {
        // 元の場所を探す
        int oldIndex = -1;
        for (int i = 0; i < player.selectedCards.length; i++) {
          if (player.selectedCards[i].card.id == card.id) {
            oldIndex = i;
            break;
          }
        }

        if (oldIndex != -1) {
          // 移動するカードを保持
          final movingCard = player.selectedCards[oldIndex];
          
          // 削除してから挿入
          player.selectedCards.removeAt(oldIndex);
          
          // 削除した分、インデックスがずれる場合の補正
          if (oldIndex < insertIndex) {
            insertIndex -= 1;
          }
          
          player.selectedCards.insert(insertIndex, movingCard);
        }
      }
    });
  }

  // --- ロジック: 手札へのドロップ処理 ---
  void _returnToHand(Player player, CardData card) {
    setState(() {
      // フィールドにあるか確認
      int index = -1;
      for (int i = 0; i < player.selectedCards.length; i++) {
        if (player.selectedCards[i].card.id == card.id) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        player.selectedCards.removeAt(index);
        player.hand.add(card);
      }
      // 手札から手札へのドロップは何もしない（あるいは末尾移動など）
    });
  }

  // --- UI: 配置済みカードの見た目 ---
  Widget _buildPlacedCardContent(PlacedCard placedCard, Function(int)? onTapSection) {
    return Container(
      width: 110,
      height: 140, // 固定高さ
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderAccent, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 2))],
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

  // --- UI: 手札カードの見た目 ---
  Widget _buildHandCardContent(CardData card) {
    const textStyle = AppTextStyles.cardHandText;
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.shadowMuted.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2))],
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

  @override
  Widget build(BuildContext context) {
    Player player = widget.players[currentPlayerIndex];
    if (isPassing) return _buildPassingScreen(player);
    return _buildGameScreen(player);
  }
}