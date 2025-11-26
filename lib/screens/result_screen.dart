import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/placed_card.dart'; 

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  const ResultScreen({super.key, required this.players});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int? timerSeconds;
  Timer? _timer;
  int? activePlayerIndex;

  void _startTimer(int index) {
    _timer?.cancel();
    setState(() {
      activePlayerIndex = index;
      timerSeconds = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timerSeconds! > 0) {
            timerSeconds = timerSeconds! - 1;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showVoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("優勝者は誰？"),
          children: widget.players.map((p) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _showWinner(p);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(p.name, style: const TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showWinner(Player winner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("🎉 採択決定！ 🎉", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(winner.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("この研究課題に予算がつきました！"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("タイトルへ戻る"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("プレゼン＆投票"),
        actions: [
          IconButton(
            icon: const Icon(Icons.how_to_vote),
            onPressed: _showVoteDialog,
            tooltip: "投票へ",
          )
        ],
      ),
      body: ListView.separated(
        itemCount: widget.players.length,
        separatorBuilder: (ctx, i) => const Divider(),
        itemBuilder: (context, index) {
          final p = widget.players[index];
          final isActive = (activePlayerIndex == index);

          return Card(
            margin: const EdgeInsets.all(8),
            color: isActive ? Colors.yellow[50] : Colors.white,
            shape: isActive ? RoundedRectangleBorder(side: const BorderSide(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(4)) : null,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前とタイマー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (isActive)
                        Text("残り: ${timerSeconds}秒", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
                      if (!isActive)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: const Text("プレゼン開始"),
                          onPressed: () => _startTimer(index),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("研究課題名：", style: TextStyle(color: Colors.grey)),
                  
                  // --- 修正箇所：新しいデータ形式（PlacedCard）に対応 ---
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: p.selectedCards.map((placedCard) {
                      // 選ばれているセクション（0:上, 1:中, 2:下）
                      final sel = placedCard.selectedSection;
                      final card = placedCard.card;

                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 選ばれている行だけ太字・大きく表示する
                            Text(card.top, style: TextStyle(
                              fontSize: sel == 0 ? 16 : 10, 
                              fontWeight: sel == 0 ? FontWeight.bold : FontWeight.normal,
                              color: sel == 0 ? Colors.black : Colors.grey
                            )),
                            Text(card.middle, style: TextStyle(
                              fontSize: sel == 1 ? 16 : 10, 
                              fontWeight: sel == 1 ? FontWeight.bold : FontWeight.normal,
                              color: sel == 1 ? Colors.black : Colors.grey
                            )),
                            Text(card.bottom, style: TextStyle(
                              fontSize: sel == 2 ? 16 : 10, 
                              fontWeight: sel == 2 ? FontWeight.bold : FontWeight.normal,
                              color: sel == 2 ? Colors.black : Colors.grey
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
            icon: const Icon(Icons.check_circle),
            label: const Text("全員の発表終了 -> 投票へ", style: TextStyle(fontSize: 18)),
            onPressed: _showVoteDialog,
          ),
        ),
      ),
    );
  }
}
