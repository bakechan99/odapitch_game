import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../models/player.dart';
import '../models/placed_card.dart';
import '../models/game_settings.dart'; // 設定モデル
import 'result_screen.dart';

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
    _showConfirmDialog(
      title: "確認",
      content: "このタイトルで決定してよろしいですか？",
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
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("キャンセル"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ダイアログを閉じる
                onConfirm(); // 処理実行
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text("OK"),
            ),
          ],
        );
      },
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
              // gradient: LinearGradient(
              //   colors: [Colors.blueGrey, Colors.black87],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("次は ${player.name} さんの番です", 
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Icon(Icons.phone_android, size: 100, color: Colors.white),
                const SizedBox(height: 30),
                const Text("スマホを渡してください", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmDialog(
                      title: "確認", 
                      content: "${player.name}さん、準備はいいですか？", 
                      onConfirm: () => setState(() => isPassing = false)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("準備OK", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: Text("${player.name} のターン")),
      body: Column(
        children: [
          // --- エリアA: 作成されたタイトル（ドラッグ並び替えエリア） ---
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.blue[50],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Padding(
                   padding: EdgeInsets.only(left: 10, bottom: 5),
                   child: Text("【研究課題名】 ドラッグで並び替え・タップで文字選択", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                 ),
                 Expanded(
                   child: DragTarget<CardData>(
                     onAccept: (card) {
                       setState(() {
                         player.hand.remove(card);
                         player.selectedCards.add(PlacedCard(card: card, selectedSection: 1));
                       });
                     },
                     builder: (context, candidateData, rejectedData) {
                       if (player.selectedCards.isEmpty) {
                         return Center(
                           child: Text("手札からここにドラッグしてください", 
                             style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                         );
                       }
                       
                       return ReorderableListView.builder(
                         scrollDirection: Axis.horizontal,
                         padding: const EdgeInsets.symmetric(horizontal: 10),
                         itemCount: player.selectedCards.length,
                         onReorder: (oldIndex, newIndex) {
                           setState(() {
                             if (oldIndex < newIndex) newIndex -= 1;
                             final item = player.selectedCards.removeAt(oldIndex);
                             player.selectedCards.insert(newIndex, item);
                           });
                         },
                         itemBuilder: (context, index) {
                           final placedCard = player.selectedCards[index];
                           // ★変更点：ここをDragStartListenerで包むことでどこでも掴めるようになる
                           return ReorderableDragStartListener(
                             key: ValueKey(placedCard),
                             index: index,
                             child: _buildPlacedCard(
                               placedCard: placedCard,
                               onTapSection: (sectionIndex) {
                                 setState(() {
                                   placedCard.selectedSection = sectionIndex;
                                 });
                               },
                               onDelete: () {
                                 setState(() {
                                   player.selectedCards.removeAt(index);
                                   player.hand.add(placedCard.card);
                                 });
                               },
                             ),
                           );
                         },
                       );
                     },
                   ),
                 ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 2),
          
          // --- エリアB: 手札エリア ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: player.hand.length,
              itemBuilder: (context, index) {
                final card = player.hand[index];
                return Draggable<CardData>(
                  data: card,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(opacity: 0.7, child: _buildHandCard(card)),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: _buildHandCard(card)),
                  child: _buildHandCard(card),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
                  onPressed: player.selectedCards.isEmpty ? null : _nextPlayer,
                  child: const Text("これで決定！", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandCard(CardData card) {
    const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
    return Container(
      width: 100, // サイズ固定
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

  Widget _buildPlacedCard({
    required PlacedCard placedCard,
    required Function(int) onTapSection,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: InkWell(onTap: () => onTapSection(0), child: _buildSectionText(placedCard.card.top, placedCard.selectedSection == 0))),
              const Divider(height: 1),
              Expanded(child: InkWell(onTap: () => onTapSection(1), child: _buildSectionText(placedCard.card.middle, placedCard.selectedSection == 1))),
              const Divider(height: 1),
              Expanded(child: InkWell(onTap: () => onTapSection(2), child: _buildSectionText(placedCard.card.bottom, placedCard.selectedSection == 2))),
            ],
          ),
          Positioned(
            right: 0, top: 0,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), topRight: Radius.circular(6))),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionText(String text, bool isSelected) {
    return Container(
      width: double.infinity,
      color: isSelected ? Colors.yellow[100] : Colors.transparent,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSelected ? 18 : 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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