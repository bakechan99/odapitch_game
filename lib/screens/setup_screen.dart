import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_data.dart';
import '../models/card_preset.dart';
import '../models/odai_preset.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../data/local_db.dart';
import '../features/setup/application/setup_controller.dart';
import '../features/setup/data/setup_repository_impl.dart';
import 'game_loop_screen.dart';
import 'passing_confirm_screen.dart';
import '../widgets/common_app_bar.dart';
import '../constants/texts.dart';
import '../widgets/setting_stepper_control.dart';
import '../widgets/time_setting_control.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/reward_ad_manager.dart'; // 追加

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
  List<OdaiPreset> _odaiPresets = const [];
  String _selectedPresetId = LocalDb.defaultPresetId;
  String _selectedOdaiPresetId = LocalDb.defaultOdaiPresetId;
  bool _isAiEnabled = false;
  late final SetupController _setupController;
  late final RewardAdManager _rewardAdManager; // 追加

  @override
  void initState() {
    super.initState();
    _setupController = SetupController(SetupRepositoryImpl());
    _rewardAdManager = RewardAdManager(); // インスタンス化
    _rewardAdManager.loadAd(); // 広告のプリロード
    _loadInitialData();
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
      _selectedOdaiPresetId = initialData.selectedOdaiPresetId;
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
        playerCount = _setupController.clampPlayerCount(
          initialData.settings.playerCount,
        );
        _syncControllerCount(); // 保存がない場合はデフォルト
      }
    });

    await _loadCardPresets();
  }

  Future<void> _loadCardPresets() async {
    final jsonText = await rootBundle.loadString('assets/card_presets.json');
    final List<dynamic> decoded = json.decode(jsonText) as List<dynamic>;
    final presets = decoded
        .map((entry) => CardPreset.fromJson(entry as Map<String, dynamic>))
        .toList();

    final hasSelected = presets.any((preset) => preset.id == _selectedPresetId);

    if (!mounted) return;

    setState(() {
      _presets = presets;
      _selectedPresetId = hasSelected
          ? _selectedPresetId
          : LocalDb.defaultPresetId;
    });

    if (!hasSelected) {
      await _setupController.saveSelectedPresetId(_selectedPresetId);
    }

    await _loadOdaiPresets(
      _resolveSelectedPresetOdaiPath(),
      preferredId: _selectedOdaiPresetId,
    );
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

  String _resolveSelectedPresetOdaiPath() {
    if (_presets.isEmpty) {
      return 'assets/odai_presets/odai_cards.json';
    }

    for (final preset in _presets) {
      if (preset.id == _selectedPresetId) {
        return preset.odaiPath;
      }
    }

    return _presets.first.odaiPath;
  }

  Future<void> _loadOdaiPresets(String odaiPath, {String? preferredId}) async {
    final jsonText = await rootBundle.loadString(odaiPath);
    final List<dynamic> decoded = json.decode(jsonText) as List<dynamic>;
    final presets = decoded
        .map((entry) => OdaiPreset.fromJson(entry as Map<String, dynamic>))
        .toList();

    final String targetId = preferredId ?? _selectedOdaiPresetId;
    final hasSelected = presets.any((preset) => preset.id == targetId);
    final fallbackId = presets.isNotEmpty
        ? presets.first.id
        : LocalDb.defaultOdaiPresetId;
    final resolvedId = hasSelected ? targetId : fallbackId;

    if (!mounted) return;

    setState(() {
      _odaiPresets = presets;
      _selectedOdaiPresetId = resolvedId;
    });

    await _setupController.saveSelectedOdaiPresetId(resolvedId);
  }

  Future<String> _resolveSelectedOdaiTheme() async {
    if (_odaiPresets.isEmpty) {
      await _loadOdaiPresets(
        _resolveSelectedPresetOdaiPath(),
        preferredId: _selectedOdaiPresetId,
      );
    }

    OdaiPreset? selectedPreset;
    for (final preset in _odaiPresets) {
      if (preset.id == _selectedOdaiPresetId) {
        selectedPreset = preset;
        break;
      }
    }
    selectedPreset ??= _odaiPresets.isNotEmpty ? _odaiPresets.first : null;

    final odai = selectedPreset?.odai.trim() ?? '';
    return odai.isEmpty ? '科研費を取れる研究テーマ' : odai;
  }

  void _updateControllers() {
    setState(_syncControllerCount);
  }

  void _syncControllerCount() {
    while (_controllers.length < playerCount) {
      // AppTexts.defaultPlayerNameWithIndex を使用
      _controllers.add(
        TextEditingController(
          text: AppTexts.defaultPlayerNameWithIndex(_controllers.length + 1),
        ),
      );
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
    // 1. 設定の保存処理（既存通り）
    await _setupController.saveSetup(
      playerNames: _controllers.map((controller) => controller.text).toList(),
      settings: GameSettings(
        presentationTimeSec: presentationTime,
        qaTimeSec: qaTime,
        playerCount: playerCount,
      ),
      selectedPresetId: _selectedPresetId,
      selectedOdaiPresetId: _selectedOdaiPresetId,
    );

    // 2. データの準備（既存通り）
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

    final odaiTheme = await _resolveSelectedOdaiTheme();

    // 3. AI設定に応じた遷移ロジック
    void navigateNext() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameLoopScreen(
            players: players,
            settings: GameSettings(
              presentationTimeSec: presentationTime,
              qaTimeSec: qaTime,
              playerCount: playerCount,
            ),
            odaiTheme: odaiTheme,
            odaiId: _selectedOdaiPresetId,
            isAiEnabled: _isAiEnabled, // ← 修正：新規引数を渡す
          ),
        ),
      );
    }

    if (_isAiEnabled) {
      // AIがONなら広告表示
      _rewardAdManager.showAd(
        onRewardEarned: navigateNext, // 視聴完了時
        onAdClosed: navigateNext, // 閉じられた時、またはエラー時（フォールバック）
      );
    } else {
      // AIがOFFならそのまま遷移
      navigateNext();
    }
  }

  // タイトルへ戻る確認ダイアログ
  Future<void> _showBackToTitleDialog() async {
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PassingConfirmScreen(
          title: AppTexts.checkPop,
          content: AppTexts.cautionBackHome,
        ),
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppTexts.setupTitle,
        onHomePressed: _showBackToTitleDialog,
        showHelp: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/GND_setup.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            // 画面からはみ出ないようにスクロール可能に
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 時間設定セクション（統合）
                //_buildSectionTitle(AppTexts.presentationTimeSection),
                //const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.9, // 横幅の80%に広げる
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        _buildTimeSlider(
                          label: AppTexts.presentationTimeLabel,
                          value: presentationTime,
                          valueWidthRatio: 0.5,
                          onDecrement: () => _changeTime(-10),
                          onIncrement: () => _changeTime(10),
                        ),
                        const SizedBox(height: 30),
                        _buildTimeSlider(
                          label: AppTexts.presentationFeedbackLabel,
                          value: qaTime,
                          valueWidthRatio: 0.5,
                          onDecrement: () => _changeQaTime(-10),
                          onIncrement: () => _changeQaTime(10),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle(AppTexts.cardPresetSection),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                                _presets.any((p) => p.id == _selectedPresetId)
                                ? _selectedPresetId
                                : null,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
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
                              await _setupController.saveSelectedPresetId(
                                value,
                              );
                              await _loadOdaiPresets(
                                _resolveSelectedPresetOdaiPath(),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                                _odaiPresets.any(
                                  (p) => p.id == _selectedOdaiPresetId,
                                )
                                ? _selectedOdaiPresetId
                                : null,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              labelText: AppTexts.odaiPresetLabel,
                              border: OutlineInputBorder(),
                            ),
                            items: _odaiPresets
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
                                _selectedOdaiPresetId = value;
                              });
                              await _setupController.saveSelectedOdaiPresetId(
                                value,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          Text(
                            "AI採点/n (広告が流れます)",
                            style: AppTextStyles.headingSection,
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              setState(() {
                                _isAiEnabled = !_isAiEnabled;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              width: 84,
                              height: 84,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isAiEnabled
                                    ? AppColors.highlights
                                    : AppColors.iconMuted,
                                border: Border.all(
                                  color: AppColors.textStrong,
                                  width: 1.6,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                width: 66,
                                height: 66,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textOnDark,
                                    width: 1.4,
                                  ),
                                ),
                                child: Text(
                                  _isAiEnabled ? 'ON' : 'OFF',
                                  style: AppTextStyles.headingSection.copyWith(
                                    fontSize: 32,
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // プレイヤー数セクション
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.transparent),
                    ),
                    child: Column(
                      children: [
                        _buildSectionTitle(AppTexts.playerCountSection),
                        const SizedBox(height: 10),
                        SettingStepperControl(
                          onDecrement: playerCount > 3
                              ? () {
                                  setState(() {
                                    playerCount--;
                                    _updateControllers();
                                  });
                                }
                              : null,
                          onIncrement: playerCount < 6
                              ? () {
                                  setState(() {
                                    playerCount++;
                                    _updateControllers();
                                  });
                                }
                              : null,
                          valueChild: SizedBox(
                            width: 300,
                            child: Container(
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  AppTexts.playerCountUnit(playerCount),
                                  style: AppTextStyles.valueLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // "③ プレイヤー名（ドラッグで入替）" -> AppTexts.setupPlayerNameSection
                _buildSectionTitle(AppTexts.setupPlayerNameSection),

                // 高さ制限(SizedBox)を削除し、リストが中身に応じて伸びるように変更
                ReorderableListView(
                  shrinkWrap: true, // 中身に合わせて高さを決定
                  physics:
                      const NeverScrollableScrollPhysics(), // 親のスクロール(SingleChildScrollView)に任せる
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(
                              Icons.drag_handle,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 30),

                // "ゲーム開始" -> AppTexts.startGameButton
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.5, // 横幅の80%に広げる)
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        child: const Text(
                          AppTexts.startGameButton,
                          style: AppTextStyles.buttonPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(title, style: AppTextStyles.headingSection),
    );
  }

  // 共通のスライダーUI構築メソッド
  Widget _buildTimeSlider({
    required String label,
    required int value,
    TextStyle? style,
    double valueWidthRatio = 0.5,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return TimeSettingControl(
      label: label,
      value: value,
      style: style,
      valueWidthRatio: valueWidthRatio,
      onDecrement: onDecrement,
      onIncrement: onIncrement,
    );
  }
}
