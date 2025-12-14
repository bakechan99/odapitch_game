import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../models/player.dart';
import '../models/placed_card.dart';
import '../models/game_settings.dart'; // 設定モデル
import 'result_screen.dart';
import '../constants/texts.dart'; // 追加
import '../widgets/custom_confirm_dialog.dart'; // 追加

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

  void _nextPlayer() {
    // ポップアップで確認
    Player player = widget.players[currentPlayerIndex];
    _showConfirmDialog(
      title: AppTexts.confirmTitle, // "確認" -> AppTexts.confirmTitle
      content: "以下のタイトルで決定しますか？\n\n「${player.researchTitle}」", // 研究タイトルを表示
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
          // 背景（画像がない場合は色のみ）
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/title_bg_2.png'), fit: BoxFit.cover),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AppTexts.nextPlayerMessage(player.name) を使用
                Text(AppTexts.nextPlayerMessage(player.name), 
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Icon(Icons.phone_android, size: 100, color: Colors.white),
                const SizedBox(height: 30),
                // "スマホを渡してください" -> AppTexts.passSmartphoneMessage
                Text(AppTexts.passSmartphoneMessage, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmDialog(
                      title: AppTexts.confirmTitle,
                      // AppTexts.areYouReady(player.name) を使用
                      content: AppTexts.areYouReady(player.name), 
                      onConfirm: () => setState(() => isPassing = false)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  // "準備OK" -> AppTexts.readyButton
                  child: const Text(AppTexts.readyButton, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )
              ],
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
              title: "確認",
              content: "タイトル画面に戻りますか？\n現在のデータは失われます。",
              onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // --- 上部エリア: 作成エリア (フィールド) ---
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[100], // 背景色
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダーテキスト
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        AppTexts.researchAreaHeader,
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // カード配置エリア (Wrap)
                    _buildFieldArea(player),
                    
                    // 領域が空の時のメッセージ
                    if (player.selectedCards.isEmpty)
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          AppTexts.handEmpty,
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // --- 下部エリア: 手札エリア ---
          DragTarget<CardData>(
            onWillAccept: (data) => data != null,
            onAccept: (card) {
              _returnToHand(player, card);
            },
            builder: (context, candidates, rejected) {
              return Container(
                height: 160, // 固定高さ
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 手札エリアのヘッダー的な装飾やボタン
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("手札", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: player.selectedCards.isEmpty ? null : _nextPlayer,
                            child: const Text(AppTexts.decideButton, style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    // 横スクロールリスト
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        itemCount: player.hand.length,
                        itemBuilder: (context, index) {
                          final card = player.hand[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 10),
                            child: Draggable<CardData>(
                              data: card,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Opacity(opacity: 0.8, child: _buildHandCardContent(card)),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildHandCardContent(card),
                              ),
                              child: _buildHandCardContent(card),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- フィールドエリアの構築 (Wrap + DragTarget) ---
  Widget _buildFieldArea(Player player) {
    List<Widget> wrapChildren = [];
    
    // カードの間に挿入ポイント(Gap)を作る
    for (int i = 0; i < player.selectedCards.length; i++) {
      // 1. 挿入ポイント (Gap)
      wrapChildren.add(_buildGapTarget(player, i));
      
      // 2. 配置済みカード
      final placedCard = player.selectedCards[i];
      wrapChildren.add(
        Draggable<CardData>(
          data: placedCard.card,
          feedback: Material(
            color: Colors.transparent,
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
    wrapChildren.add(_buildGapTarget(player, player.selectedCards.length));

    return Wrap(
      spacing: 0, // Gapで調整するため0
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: wrapChildren,
    );
  }

  // --- 隙間 (挿入ポイント) のターゲット ---
  Widget _buildGapTarget(Player player, int insertIndex) {
    return DragTarget<CardData>(
      onWillAccept: (data) => data != null,
      onAccept: (card) {
        _onDropToField(player, card, insertIndex);
      },
      builder: (context, candidates, rejected) {
        // ドラッグ中のアイテムが上に来たらスペースを広げる
        if (candidates.isNotEmpty) {
          return Container(
            width: 110, // カードと同じくらいの幅
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2, style: BorderStyle.solid),
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.blue)),
          );
        }
        // 通常時は目に見えないが判定はある領域
        return Container(
          width: 20, // ヒット判定幅
          height: 140,
          color: Colors.transparent,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
        color: isSelected ? Colors.yellow[100] : Colors.transparent,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSelected ? 16 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // --- UI: 手札カードの見た目 ---
  Widget _buildHandCardContent(CardData card) {
    const textStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87);
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(card.top, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: Colors.grey.shade200),
          Text(card.middle, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: Colors.grey.shade200),
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