import 'package:flutter/material.dart';
import '../models/player.dart';
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

  @override
  Widget build(BuildContext context) {
    Player player = widget.players[currentPlayerIndex];

    if (isPassing) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("次は ${player.name} さんの番です", style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              const Icon(Icons.phone_android, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("スマホを渡してください", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isPassing = false;
                  });
                },
                child: const Text("準備OK（自分の番です）"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("${player.name} のターン")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("カードをタップしてタイトルを作成してください", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // 選択済みエリア
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.blue[50],
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("【研究課題名】", style: TextStyle(color: Colors.blue)),
                Expanded(
                  child: player.selectedCards.isEmpty
                      ? const Center(child: Text("ここをタップしたカードが入ります"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: player.selectedCards.length,
                          itemBuilder: (context, index) {
                            final card = player.selectedCards[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  player.selectedCards.removeAt(index);
                                  player.hand.add(card);
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(card.top, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(card.middle, style: const TextStyle(fontSize: 10)),
                                      Text(card.bottom, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const Divider(),
          // 手札エリア
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
              ),
              itemCount: player.hand.length,
              itemBuilder: (context, index) {
                final card = player.hand[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      player.hand.removeAt(index);
                      player.selectedCards.add(card);
                    });
                  },
                  child: Card(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(card.top, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(card.middle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(card.bottom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: player.selectedCards.isEmpty ? null : _nextPlayer,
                  child: const Text("これで決定！"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}