import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_data.dart';
import '../models/card_preset.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../data/local_db.dart';
import '../features/setup/application/setup_controller.dart';
import '../features/setup/data/setup_repository_impl.dart';
import 'game_loop_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import '../constants/texts.dart';
import '../widgets/custom_confirm_dialog.dart';
import '../widgets/time_setting_control.dart';
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
  int presentationTime = GameSettings.defaultPresentationTimeSec;
  int qaTime = GameSettings.defaultQaTimeSec;
  final List<TextEditingController> _controllers = [];
  List<CardPreset> _presets = const [];
  String _selectedPresetId = LocalDb.defaultPresetId;
  late final SetupController _setupController;

  @override
  void initState() {
    super.initState();
    _setupController = SetupController(SetupRepositoryImpl());
    _loadInitialData();
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
  Future<void> _loadInitialData() async {
    final initialData = await _setupController.loadInitialData();

    if (!mounted) return;

    setState(() {
      _selectedPresetId = initialData.selectedPresetId;
      presentationTime = initialData.settings.presentationTimeSec;
      qaTime = initialData.settings.qaTimeSec;

      final savedNames = initialData.playerNames;
      if (savedNames.isNotEmpty) {
        playerCount = _setupController.clampPlayerCount(savedNames.length);
        _controllers.clear();
        for (final String name in savedNames) {
          _controllers.add(TextEditingController(text: name));
        }
        _syncControllerCount();
      } else {
        playerCount = _setupController.clampPlayerCount(initialData.settings.playerCount);
        _syncControllerCount(); // 保存がない場合はデフォルト
      }
    });
  }

  Future<void> _loadCardPresets() async {
    final jsonText = await rootBundle.loadString('assets/card_presets.json');
    final List<dynamic> decoded = json.decode(jsonText) as List<dynamic>;
    final presets = decoded
        .map((entry) => CardPreset.fromJson(entry as Map<String, dynamic>))
        .toList();

    final selected = await _setupController.loadSelectedPresetId();
    final hasSelected = presets.any((preset) => preset.id == selected);

    if (!mounted) return;

    setState(() {
      _presets = presets;
      _selectedPresetId = hasSelected ? selected : LocalDb.defaultPresetId;
    });

    if (!hasSelected) {
      await _setupController.saveSelectedPresetId(_selectedPresetId);
    }
  }

  Future<String> _resolveSelectedPresetPath() async {
    if (_presets.isEmpty) {
      return 'assets/presets/cards.json';
    }

    final selected = _presets.where((preset) => preset.id == _selectedPresetId);
    if (selected.isNotEmpty) {
      return selected.first.path;
    }

    return _presets.first.path;
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
      if (presentationTime > 60) presentationTime = 60; // 最大1分
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
    await _setupController.saveSetup(
      playerNames: _controllers.map((controller) => controller.text).toList(),
      settings: GameSettings(
        presentationTimeSec: presentationTime,
        qaTimeSec: qaTime,
        playerCount: playerCount,
      ),
      selectedPresetId: _selectedPresetId,
    );

    final presetPath = await _resolveSelectedPresetPath();
    final String response = await rootBundle.loadString(presetPath);
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
    GameSettings settings = GameSettings(
      presentationTimeSec: presentationTime,
      qaTimeSec: qaTime,
      playerCount: playerCount,
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
        centerTitle: true,
        automaticallyImplyLeading: false, // 自動の戻るボタンを削除
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _showBackToTitleDialog,
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
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
            // 時間設定セクション（統合）
            _buildSectionTitle(AppTexts.presentationTimeSection),
            const SizedBox(height: 10),
            

            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child:Column(
                children: [
                  _buildTimeSlider(
                    label: AppTexts.presentationTimeLabel,
                    value: presentationTime,
                    onDecrement: () => _changeTime(-10),
                    onIncrement: () => _changeTime(10),
                  ),
                  const SizedBox(height: 20),
                  _buildTimeSlider(
                    label: AppTexts.presentationFeedbackLabel,
                    value: qaTime,
                    onDecrement: () => _changeQaTime(-10),
                    onIncrement: () => _changeQaTime(10),
                  ),
                ],
              )
            ),
            
            const SizedBox(height: 20),

            // プレイヤー数セクション
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

            // カードプリセットセクション
            _buildSectionTitle(AppTexts.cardPresetSection),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _presets.any((p) => p.id == _selectedPresetId) ? _selectedPresetId : null,
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
                await _setupController.saveSelectedPresetId(value);
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
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.borderLight),
                    ),
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
            Center(
              child:FractionallySizedBox(
                widthFactor: 0.5, // 横幅の80%に広げる)
                child:SizedBox(
                  width: double.infinity, 
                  height: 60, 
                  child: ElevatedButton(
                    onPressed: _startGame, 
                    child: const Text(
                      AppTexts.startGameButton,
                      style: AppTextStyles.buttonPrimary
                    )
                  )
                ),
              )
            ),
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
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return TimeSettingControl(
      label: label,
      value: value,
      onDecrement: onDecrement,
      onIncrement: onIncrement,
    );
  }
}