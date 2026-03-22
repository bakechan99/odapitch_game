import 'package:audioplayers/audioplayers.dart'; // 音楽用
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'setup_screen.dart'; // 「新規ゲーム」を押した後の行き先
import 'help_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../constants/texts.dart'; // 追加: 定数テキストのインポート
import '../widgets/title_button.dart'; // 追加: カスタムボタンのインポート
import '../constants/app_colors.dart';
import '../widgets/custom_banner_ad.dart';
  

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // 音楽プレイヤーの作成
  final AudioPlayer _audioPlayer = AudioPlayer();
  static final Uri _termsUri = Uri.parse('https://example.com/terms');

  @override
  void initState() {
    super.initState();
    _playBGM();
  }

  // BGMを再生する関数
  void _playBGM() async {
    // ※ assets/audio/title_bgm.mp3 がある場合のみ再生されます
    // ループ再生の設定
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // 再生開始 (ファイルがないとエラーになるのでtry-catchしています)
    try {
      await _audioPlayer.play(AssetSource('audio/title_bgm.mp3'));
    } catch (e) {
      debugPrint("BGMファイルが見つかりません: $e");
    }
  }

  // 画面が閉じるとき（ゲーム開始時など）に音楽を止める
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _openTerms() async {
    final launched = await launchUrl(_termsUri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('利用規約ページを開けませんでした')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox.expand(
                        child: Image.asset(
                          'assets/images/GND_title_up.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: AspectRatio(
                            aspectRatio: 3.0,
                            child: TitleButton(
                              label: AppTexts.newGameButton,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SetupScreen(),
                                  ),
                                );
                              },
                              borderColor: AppColors.titleStartButtonBorder,
                              fillColor: AppColors.titleStartButtonNormalTop,
                              textColor: AppColors.titleStartButtonText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.error_outline_outlined),
                              iconSize: 48,
                              color: AppColors.textOnDark,
                              tooltip: AppTexts.goTerms,
                              onPressed: _openTerms,
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              iconSize: 48,
                              color: AppColors.textOnDark,
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
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.4,
                        child: AspectRatio(
                          aspectRatio: 3.0,
                          child: TitleButton(
                            label: AppTexts.goHelp,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HelpScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: constraints.maxWidth * 0.4,
                        child: AspectRatio(
                          aspectRatio: 3.0,
                          child: TitleButton(
                            label: AppTexts.goHistory,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HistoryScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox.expand(
                    child: Image.asset(
                      'assets/images/GND_title_down.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
              );
            },
          ),
          const CustomBannerAd(),
        ],
      ),
    );
  }
}