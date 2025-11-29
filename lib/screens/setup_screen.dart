import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 保存用
import '../models/card_data.dart';
import '../models/player.dart';
import '../models/game_settings.dart'; // 新規作成した設定モデル
import 'game_loop_screen.dart';
import '../constants/texts.dart'; // 追加

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int playerCount = 3;
  int presentationTime = 30; // デフォルト30秒
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerNames(); // 保存された名前を読み込む
  }

  // --- 保存機能 ---
  Future<void> _loadPlayerNames() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList('playerNames');
    
    setState(() {
      if (savedNames != null && savedNames.isNotEmpty) {
        playerCount = max(3, min(8, savedNames.length));
        _controllers.clear();
        for (String name in savedNames) {
          _controllers.add(TextEditingController(text: name));
        }
      } else {
        _updateControllers(); // 保存がない場合はデフォルト
      }
    });
  }

  Future<void> _savePlayerNames() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> names = _controllers.map((c) => c.text).toList();
    await prefs.setStringList('playerNames', names);
  }

  void _updateControllers() {
    setState(() {
      while (_controllers.length < playerCount) {
        // "プレイヤー" -> AppTexts.defaultPlayerName
        _controllers.add(TextEditingController(text: "${AppTexts.defaultPlayerName}${_controllers.length + 1}"));
      }
      while (_controllers.length > playerCount) {
        _controllers.removeLast();
      }
    });
  }

  // --- 時間設定の増減 ---
  void _changeTime(int amount) {
    setState(() {
      presentationTime += amount;
      if (presentationTime < 10) presentationTime = 10; // 最小10秒
      if (presentationTime > 300) presentationTime = 300; // 最大5分
    });
  }

  // --- ゲーム開始 ---
  Future<void> _startGame() async {
    // 名前を保存
    await _savePlayerNames();

    final String response = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> data = json.decode(response);
    List<CardData> deck = data.map((json) => CardData.fromJson(json)).toList();
    deck.shuffle(Random());

    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      Player p = Player(name: _controllers[i].text);
      for (int j = 0; j < 6; j++) {
        if (deck.isNotEmpty) p.hand.add(deck.removeLast());
      }
      players.add(p);
    }

    if (!mounted) return;
    
    // 設定をまとめて次の画面へ渡す
    GameSettings settings = GameSettings(presentationTimeSec: presentationTime);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameLoopScreen(players: players, settings: settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ゲーム設定")),
      body: SingleChildScrollView( // 画面からはみ出ないようにスクロール可能に
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle("① 参加人数"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(onPressed: playerCount > 3 ? () { setState(() { playerCount--; _updateControllers(); }); } : null, icon: const Icon(Icons.remove)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("$playerCount人", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                IconButton.filled(onPressed: playerCount < 8 ? () { setState(() { playerCount++; _updateControllers(); }); } : null, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle("② プレゼン時間"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(onPressed: () => _changeTime(-10), icon: const Text("-10秒")),
                const SizedBox(width: 10),
                Text("${presentationTime}秒", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                IconButton.outlined(onPressed: () => _changeTime(10), icon: const Text("+10秒")),
              ],
            ),
            const SizedBox(height: 20),

            // "③ プレイヤー名（ドラッグで入替）" -> AppTexts.setupPlayerNameSection
            _buildSectionTitle(AppTexts.setupPlayerNameSection),
            SizedBox(
              height: 200, // リストの高さ制限
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final item = _controllers.removeAt(oldIndex);
                    _controllers.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _controllers.length; i++)
                    ListTile(
                      key: ValueKey(_controllers[i]),
                      leading: const Icon(Icons.drag_handle),
                      title: TextField(controller: _controllers[i]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),

            // "ゲーム開始" -> AppTexts.startGameButton
            SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _startGame, child: const Text(AppTexts.startGameButton, style: TextStyle(fontSize: 20)))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)));
  }
}