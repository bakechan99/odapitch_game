import 'package:flutter/material.dart';
import 'package:kakenhi_game/constants/app_colors.dart';
import '../constants/texts.dart';
import '../constants/app_text_styles.dart';
import '../data/local_db.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // static const String _keyBgmEnabled = 'bgm_enabled'; // BGM未使用
  static const String _keySeEnabled = 'se_enabled';
  // static const String _keyBgmVolume = 'bgm_volume';   // BGM未使用
  static const String _keySeVolume = 'se_volume';

  // bool _bgmEnabled = true; // BGM未使用
  bool _seEnabled = true;
  // double _bgmVolume = 0.8; // BGM未使用
  double _seVolume = 0.8;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // final bgmEnabled = await LocalDb.instance.loadAppSetting(_keyBgmEnabled); // BGM未使用
    final seEnabled = await LocalDb.instance.loadAppSetting(_keySeEnabled);
    // final bgmVolume = await LocalDb.instance.loadAppSetting(_keyBgmVolume);   // BGM未使用
    final seVolume = await LocalDb.instance.loadAppSetting(_keySeVolume);

    if (!mounted) return;

    setState(() {
      // _bgmEnabled = (bgmEnabled ?? '1') == '1'; // BGM未使用
      _seEnabled = (seEnabled ?? '1') == '1';
      // _bgmVolume = double.tryParse(bgmVolume ?? '') ?? 0.8; // BGM未使用
      _seVolume = double.tryParse(seVolume ?? '') ?? 0.8;
      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    await LocalDb.instance.saveAppSetting(key, value ? '1' : '0');
  }

  Future<void> _saveDouble(String key, double value) async {
    await LocalDb.instance.saveAppSetting(key, value.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: AppColors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/GND_setting.png',
              fit: BoxFit.cover,
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      AppTexts.settingsAudioSection, 
                      style: AppTextStyles.headingSection.copyWith(
                        fontSize: 30
                      )
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(AppTexts.settingsSeEnabled),
                      value: _seEnabled,
                      onChanged: (value) async {
                        setState(() => _seEnabled = value);
                        await _saveBool(_keySeEnabled, value);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${AppTexts.settingsSeVolume} (${(_seVolume * 100).round()}%)', 
                      style: AppTextStyles.labelField.copyWith(
                        fontSize: 30,
                      )
                    ),
                    Slider(
                      value: _seVolume,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() => _seVolume = value);
                      },
                      onChangeEnd: (value) async {
                        await _saveDouble(_keySeVolume, value);
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
