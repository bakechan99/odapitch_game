import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/local_db.dart';
import '../models/card_data.dart';
import '../models/card_preset.dart';
import '../models/player.dart';
import '../models/game_settings.dart'; // 新規作成した設定モデル
import 'game_loop_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import '../constants/texts.dart'; // 追加
import '../widgets/custom_confirm_dialog.dart'; // 追加
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Setup UI for player names and time settings before starting a game.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

/// Holds setup state and persists player names to local SQLite.
class _SetupScreenState extends State<SetupScreen> {
  int playerCount = 3;
  int presentationTime = 30; // デフォルト30秒
  int qaTime = 30; // 質疑応答時間 デフォルト30秒
  List<CardPreset> _presets = [];
  String _selectedPresetId = LocalDb.defaultPresetId;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerNames(); // 保存された名前を読み込む
    _loadCardPresets();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- 保存機能 ---
  Future<void> _loadPlayerNames() async {
    final savedNames = await LocalDb.instance.loadPlayerNames();

    if (!mounted) return;

    setState(() {
      if (savedNames.isNotEmpty) {
        playerCount = max(3, min(8, savedNames.length));
        _controllers.clear();
        for (String name in savedNames) {
          _controllers.add(TextEditingController(text: name));
        }
        _syncControllerCount();
      } else {
        _syncControllerCount(); // 保存がない場合はデフォルト
      }
    });
  }

  Future<void> _savePlayerNames() async {
    List<String> names = _controllers.map((c) => c.text).toList();
    await LocalDb.instance.savePlayerNames(names);
  }

  Future<void> _loadCardPresets() async {
    List<CardPreset> loadedPresets;

    try {
      final response = await rootBundle.loadString('assets/card_presets.json');
      final List<dynamic> data = json.decode(response);
      loadedPresets = data
          .map((item) => CardPreset.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      loadedPresets = [
        CardPreset(
          id: LocalDb.defaultPresetId,
          name: '標準（既存）',
          path: 'assets/cards.json',
        ),
      ];
    }

    if (loadedPresets.isEmpty) {
      loadedPresets = [
        CardPreset(
          id: LocalDb.defaultPresetId,
          name: '標準（既存）',
          path: 'assets/cards.json',
        ),
      ];
    }

    final savedPresetId = await LocalDb.instance.loadSelectedPresetId(
      fallback: loadedPresets.first.id,
    );

    final selectedPresetId = loadedPresets.any((preset) => preset.id == savedPresetId)
        ? savedPresetId
        : loadedPresets.first.id;

    if (!mounted) return;

    setState(() {
      _presets = loadedPresets;
      _selectedPresetId = selectedPresetId;
    });

    if (selectedPresetId != savedPresetId) {
      await LocalDb.instance.saveSelectedPresetId(selectedPresetId);
    }
  }

  void _updateControllers() {
    setState(_syncControllerCount);
  }

  void _syncControllerCount() {
    while (_controllers.length < playerCount) {
      // AppTexts.defaultPlayerNameWithIndex を使用
      _controllers.add(TextEditingController(text: AppTexts.defaultPlayerNameWithIndex(_controllers.length + 1)));
    }
    while (_controllers.length > playerCount) {
      final controller = _controllers.removeLast();
      controller.dispose();
    }
  }

  // --- 時間設定の増減 ---
  void _changeTime(int amount) {
    setState(() {
      presentationTime += amount;
      if (presentationTime < 10) presentationTime = 10; // 最小10秒
      if (presentationTime > 600) presentationTime = 600; // 最大10分
    });
  }

  void _changeQaTime(int amount) {
    setState(() {
      qaTime += amount;
      if (qaTime < 10) qaTime = 10; // 最小10秒に変更
      if (qaTime > 600) qaTime = 600; // 最大10分
    });
  }

  // --- ゲーム開始 ---
  Future<void> _startGame() async {
    // 1. 入力バリデーション: 空文字の場合はデフォルト名を設定
    for (int i = 0; i < playerCount; i++) {
      if (_controllers[i].text.trim().isEmpty) {
        _controllers[i].text = AppTexts.defaultPlayerNameWithIndex(i + 1);
      }
    }

    // 2. 名前を保存 (バリデーション済みの名前が保存されます)
    await _savePlayerNames();

<<<<<<< HEAD
    String selectedPath = 'assets/cards.json';
    for (final preset in _presets) {
      if (preset.id == _selectedPresetId) {
        selectedPath = preset.path;
        break;
      }
    }

    await LocalDb.instance.saveSelectedPresetId(_selectedPresetId);

    final String response = await rootBundle.loadString(selectedPath);
=======
    // 3. 非同期処理(保存)の待機後にウィジェットが存在しているか確認
    if (!mounted) return;

    final String response = await rootBundle.loadString('assets/cards.json');
>>>>>>> 1b6039a0bcdc50e7b2858ac2b610094c99ced5c6
    final List<dynamic> data = json.decode(response);
    List<CardData> deck = data.map((json) => CardData.fromJson(json)).toList();
    deck.shuffle(Random());

    List<Player> players = [];
    for (int i = 0; i < playerCount; i++) {
      // コントローラーの値は既に整形済みなのでそのまま使用
      Player p = Player(name: _controllers[i].text);
      for (int j = 0; j < 6; j++) {
        if (deck.isNotEmpty) p.hand.add(deck.removeLast());
      }
      players.add(p);
    }

    if (!mounted) return;
    
    // 設定をまとめて次の画面へ渡す
    GameSettings settings = GameSettings(
      presentationTimeSec: presentationTime,
      qaTimeSec: qaTime,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameLoopScreen(players: players, settings: settings)),
    );
  }

  // タイトルへ戻る確認ダイアログ
  void _showBackToTitleDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: AppTexts.checkPop,
        content: AppTexts.cautionBackHome,
        onConfirm: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        cancelText: AppTexts.cancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.setupTitle),
        automaticallyImplyLeading: false, // 自動の戻るボタンを削除
        leadingWidth: 96,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: AppTexts.goHome,
              onPressed: _showBackToTitleDialog,
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: AppTexts.goHelp,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppTexts.goSettings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // 画面からはみ出ないようにスクロール可能に
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionTitle(AppTexts.playerCountSection),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(onPressed: playerCount > 3 ? () { setState(() { playerCount--; _updateControllers(); }); } : null, icon: const Icon(Icons.remove)),
                // "$playerCount人" -> AppTexts.playerCountUnit(playerCount)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(AppTexts.playerCountUnit(playerCount), style: AppTextStyles.valueLarge)),
                IconButton.filled(onPressed: playerCount < 8 ? () { setState(() { playerCount++; _updateControllers(); }); } : null, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 20),
            
            // 時間設定セクション（統合）
            _buildSectionTitle(AppTexts.presentationTimeSection),
            const SizedBox(height: 10),
            
            // プレゼン時間設定
            _buildTimeSlider(
              label: AppTexts.presentationTimeLabel,
              value: presentationTime,
              onChanged: (val) {
                setState(() {
                  presentationTime = val.toInt();
                });
              },
              onDecrement: () => _changeTime(-10),
              onIncrement: () => _changeTime(10),
            ),
            const SizedBox(height: 10),

            // 質疑応答時間設定
            _buildTimeSlider(
              label: AppTexts.presentationFeedbackLabel,
              value: qaTime,
              onChanged: (val) {
                setState(() {
                  qaTime = val.toInt();
                });
              },
              onDecrement: () => _changeQaTime(-10),
              onIncrement: () => _changeQaTime(10),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle(AppTexts.cardPresetSection),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _presets.any((preset) => preset.id == _selectedPresetId)
                  ? _selectedPresetId
                  : null,
              decoration: const InputDecoration(
                labelText: AppTexts.cardPresetLabel,
                border: OutlineInputBorder(),
              ),
              items: _presets
                  .map(
                    (preset) => DropdownMenuItem<String>(
                      value: preset.id,
                      child: Text(preset.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  _selectedPresetId = value;
                });
                await LocalDb.instance.saveSelectedPresetId(value);
              },
            ),
            const SizedBox(height: 20),

            // "③ プレイヤー名（ドラッグで入替）" -> AppTexts.setupPlayerNameSection
            _buildSectionTitle(AppTexts.setupPlayerNameSection),
            
            // 高さ制限(SizedBox)を削除し、リストが中身に応じて伸びるように変更
            ReorderableListView(
              shrinkWrap: true, // 中身に合わせて高さを決定
              physics: const NeverScrollableScrollPhysics(), // 親のスクロール(SingleChildScrollView)に任せる
              buildDefaultDragHandles: false, // デフォルトのドラッグハンドルを無効化
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _controllers.removeAt(oldIndex);
                  _controllers.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _controllers.length; i++)
                  Card(
                    key: ValueKey(_controllers[i]),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: AppColors.surface,
                    child: ListTile(
                      title: TextField(
                        controller: _controllers[i],
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle, color: AppColors.textMuted),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 30),

            // "ゲーム開始" -> AppTexts.startGameButton
            SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _startGame, child: const Text(AppTexts.startGameButton, style: AppTextStyles.buttonPrimary))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: AppTextStyles.headingSection));
  }

  // 共通のスライダーUI構築メソッド
  Widget _buildTimeSlider({
    required String label,
    required int value,
    required ValueChanged<double> onChanged,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ラベル表示
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(label, style: AppTextStyles.labelField),
        ),
        const SizedBox(height: 5),
        // 現在値の表示
        Center(
          child: Text(
            AppTexts.secondsUnit(value),
            style: AppTextStyles.valueLarge,
          ),
        ),
        Row(
          children: [
            // マイナスボタン
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 32, color: AppColors.textMuted),
              onPressed: onDecrement,
            ),
            // スライダー
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 10,
                max: 600,
                divisions: 59, // (600-10)/10 = 59分割 (10秒刻み)
                label: AppTexts.secondsUnit(value),
                onChanged: onChanged,
              ),
            ),
            // プラスボタン
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 32, color: AppColors.textMuted),
              onPressed: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}