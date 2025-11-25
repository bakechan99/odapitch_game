import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundleを使うため
import '../models/card_data.dart';      // モデルを読み込む
import '../models/player.dart';
import 'game_loop_screen.dart';         // 次の画面を読み込む

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int playerCount = 3;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  void _updateControllers() {
    while (_controllers.length < playerCount) {
      _controllers.add(TextEditingController(text: "プレイヤー${_controllers.length + 1}"));
    }
    while (_controllers.length > playerCount) {
      _controllers.removeLast();
    }
  }

  Future<void> _startGame() async {
    // JSONデータの読み込み
    final String response = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> data = json.decode(response);
    List<CardData> deck = data.map((json) => CardData.fromJson(json)).toList();

    deck.shuffle(Random());

    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      Player p = Player(name: _controllers[i].text);
      for (int j = 0; j < 6; j++) {
        if (deck.isNotEmpty) {
          p.hand.add(deck.removeLast());
        }
      }
      players.add(p);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameLoopScreen(players: players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("科研費ゲーム - 設定")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("プレイヤー人数を選択", style: TextStyle(fontSize: 18)),
            Slider(
              value: playerCount.toDouble(),
              min: 3,
              max: 6,
              divisions: 3,
              label: "$playerCount人",
              onChanged: (val) {
                setState(() {
                  playerCount = val.toInt();
                  _updateControllers();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: playerCount,
                itemBuilder: (context, index) {
                  return TextField(
                    controller: _controllers[index],
                    decoration: InputDecoration(labelText: "プレイヤー ${index + 1} の名前"),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("ゲーム開始！", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}