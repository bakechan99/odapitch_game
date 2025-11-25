import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';

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
                  Wrap(
                    spacing: 4,
                    children: p.selectedCards.map((c) {
                      return Chip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.top, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(c.middle, style: const TextStyle(fontSize: 10)),
                            Text(c.bottom, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        elevation: 2,
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