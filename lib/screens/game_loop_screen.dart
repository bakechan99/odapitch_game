import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../models/player.dart';
import '../models/placed_card.dart'; // 新しいモデル
import 'result_screen.dart';

class GameLoopScreen extends StatefulWidget {
  final List<Player> players;
  const GameLoopScreen({super.key, required this.players});

  @override
  State<GameLoopScreen> createState() => _GameLoopScreenState();
}

class _GameLoopScreenState extends State<GameLoopScreen> {
  int currentPlayerIndex = 0;
  bool isPassing = true;

  void _nextPlayer() {
    if (currentPlayerIndex < widget.players.length - 1) {
      setState(() {
        currentPlayerIndex++;
        isPassing = true;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(players: widget.players)),
      );
    }
  }

  // --- 画面1: 順番確認（スマホ受渡）画面 ---
  Widget _buildPassingScreen(Player player) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Container(
            decoration: const BoxDecoration(
              // image: DecorationImage(
              //   // タイトルと同じ背景を使用（なければ色のみ）
              //   // image: AssetImage('assets/images/title_bg.png'), 
              //   fit: BoxFit.cover,
              // ),
              color: Colors.blueGrey, // 画像がない時の色
            ),
          ),
          // 黒半透明フィルター
          Container(color: Colors.black.withOpacity(0.5)),
          
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
                    setState(() {
                      isPassing = false;
                    });
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
            height: 220, // カードの高さに合わせて調整
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
                     // 手札からドラッグされた時の受け入れ処理
                     onAccept: (card) {
                       setState(() {
                         player.hand.remove(card);
                         // 初期状態は真ん中(1)を選択にして追加
                         player.selectedCards.add(PlacedCard(card: card, selectedSection: 1));
                       });
                     },
                     builder: (context, candidateData, rejectedData) {
                       // リストが空の時の表示
                       if (player.selectedCards.isEmpty) {
                         return Center(
                           child: Text("手札からここにドラッグしてください", 
                             style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                         );
                       }
                       
                       // 並び替え可能なリスト
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
                           // リスト内のカード表示
                           return _buildPlacedCard(
                             key: ValueKey(placedCard), // 重要：一意なキー
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
          
          // --- エリアB: 手札エリア（ドラッグ元） ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75, // カードの縦横比
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: player.hand.length,
              itemBuilder: (context, index) {
                final card = player.hand[index];
                // Draggableで包むことでドラッグ可能にする
                return Draggable<CardData>(
                  data: card,
                  feedback: Material( // ドラッグ中の見た目（半透明）
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.7,
                      child: _buildHandCard(card),
                    ),
                  ),
                  childWhenDragging: Opacity( // ドラッグ元の見た目
                    opacity: 0.3,
                    child: _buildHandCard(card),
                  ),
                  child: _buildHandCard(card), // 通常時の見た目
                );
              },
            ),
          ),

          // 決定ボタン
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

  // 手札にある時のカードデザイン（文字サイズ均一）
  Widget _buildHandCard(CardData card) {
    // 共通の文字スタイル
    const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
    
    return Container(
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
          // 区分け線
          Divider(height: 1, color: Colors.grey.shade200),
          Text(card.middle, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Divider(height: 1, color: Colors.grey.shade200),
          Text(card.bottom, style: textStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // 配置済み（タイトル作成エリア）のカードデザイン
  // 選択された段が強調され、タップで切り替え可能
  Widget _buildPlacedCard({
    required Key key,
    required PlacedCard placedCard,
    required Function(int) onTapSection,
    required VoidCallback onDelete,
  }) {
    return Container(
      key: key,
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
              // 上段
              Expanded(
                child: InkWell(
                  onTap: () => onTapSection(0),
                  child: _buildSectionText(placedCard.card.top, placedCard.selectedSection == 0),
                ),
              ),
              const Divider(height: 1),
              // 中段
              Expanded(
                child: InkWell(
                  onTap: () => onTapSection(1),
                  child: _buildSectionText(placedCard.card.middle, placedCard.selectedSection == 1),
                ),
              ),
              const Divider(height: 1),
              // 下段
              Expanded(
                child: InkWell(
                  onTap: () => onTapSection(2),
                  child: _buildSectionText(placedCard.card.bottom, placedCard.selectedSection == 2),
                ),
              ),
            ],
          ),
          // 削除ボタン（右上）
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), topRight: Radius.circular(6)),
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // セクションごとの文字表示（選択中は大きく太く）
  Widget _buildSectionText(String text, bool isSelected) {
    return Container(
      width: double.infinity,
      color: isSelected ? Colors.yellow[100] : Colors.transparent, // 選択中は背景色も変える
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          // 選択中はサイズアップ＆太字、非選択はグレーアウト
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

    if (isPassing) {
      return _buildPassingScreen(player);
    }
    return _buildGameScreen(player);
  }
}