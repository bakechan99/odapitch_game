import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_data.dart';
import '../models/player.dart';
import 'game_loop_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int playerCount = 3;
  // コントローラーをリストで管理（並び替え時にこれを操作します）
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // 初期化：3人分作成
    _updateControllers();
  }

  // 人数に合わせてコントローラーを増減させる関数
  void _updateControllers() {
    setState(() {
      // 足りない分を追加
      while (_controllers.length < playerCount) {
        // 名前が空欄だと寂しいので初期値を入れておきます
        _controllers.add(TextEditingController(text: "プレイヤー${_controllers.length + 1}"));
      }
      // 多い分を削除（後ろから）
      while (_controllers.length > playerCount) {
        _controllers.removeLast();
      }
    });
  }

  // ＋ボタンの処理（最大8人）
  void _incrementPlayers() {
    if (playerCount < 8) {
      setState(() {
        playerCount++;
        _updateControllers();
      });
    }
  }

  // －ボタンの処理（最小3人）
  void _decrementPlayers() {
    if (playerCount > 3) {
      setState(() {
        playerCount--;
        _updateControllers();
      });
    }
  }

  // リストを並び替えた時の処理（ドラッグ＆ドロップで呼ばれる）
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // 並び替えの作法（移動先が後ろの場合の補正）
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      // リストから抜いて、新しい場所に挿入
      final item = _controllers.removeAt(oldIndex);
      _controllers.insert(newIndex, item);
    });
  }

  Future<void> _startGame() async {
    // データ読み込み
    final String response = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> data = json.decode(response);
    List<CardData> deck = data.map((json) => CardData.fromJson(json)).toList();

    deck.shuffle(Random());

    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      // _controllersの順番通りにプレイヤーを作成
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
      appBar: AppBar(title: const Text("プレイヤー設定")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. 人数変更エリア (+ - ボタン) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("参加人数: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  // マイナスボタン
                  IconButton.filled(
                    onPressed: playerCount > 3 ? _decrementPlayers : null, // 3人なら押せない
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                  const SizedBox(width: 20),
                  // 人数表示
                  Text(
                    "$playerCount人",
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  // プラスボタン
                  IconButton.filled(
                    onPressed: playerCount < 8 ? _incrementPlayers : null, // 8人なら押せない
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            const Text("左のハンドル（≡）を長押しで順番を入れ替えられます", 
              style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),

            // --- 2. 名前入力リスト（並び替え可能） ---
            Expanded(
              child: ReorderableListView(
                onReorder: _onReorder,
                children: [
                  // コントローラーの数だけリストを作る
                  for (int i = 0; i < _controllers.length; i++)
                    Card(
                      // ReorderableListViewにはKeyが必須。コントローラー自体をKeyにする
                      key: ValueKey(_controllers[i]), 
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        // 左端のハンドルアイコン（ここを持ってドラッグ）
                        leading: ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle, size: 30, color: Colors.grey),
                        ),
                        title: TextField(
                          controller: _controllers[i],
                          decoration: InputDecoration(
                            labelText: "${i + 1}番目のプレイヤー名", // 順番が変わっても「1番目」等の表示は正しい位置に出る
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- 3. ゲーム開始ボタン ---
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: const Text("ゲームを開始", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}