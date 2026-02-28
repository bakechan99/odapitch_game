import 'package:audioplayers/audioplayers.dart'; // 音楽用
import 'package:flutter/material.dart';
import 'setup_screen.dart'; // 「新規ゲーム」を押した後の行き先
import 'help_screen.dart';
import 'settings_screen.dart';
import '../constants/texts.dart'; // 追加: 定数テキストのインポート
import '../widgets/title_button.dart'; // 追加: カスタムボタンのインポート
import '../widgets/decorative_band.dart';
import '../constants/app_colors.dart';
  

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // 音楽プレイヤーの作成
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stackを使うと、要素を「重ねて」表示できます（背景の上にボタン、など）
      body: LayoutBuilder(
        builder: (context, constraints) {
          const topBandHeight = 18.0;
          const bottomBandHeight = 18.0;
          const accentBandHeight = 12.0;
          const middleBandHeight = 10.0;
          const middleBandToTitleGap = 20.0;
          const titleToButtonGap = 28.0;
          const buttonGap = 14.0;
          const bottomGap = 28.0;
          final fillColor = AppColors.surfaceTheme;
          final accentFillColor = AppColors.actionPrimary.withValues(alpha: 0.55);

          final titleFontSize = (constraints.maxWidth * 0.09).clamp(28.0, 56.0);
          final startButtonHeight = (constraints.maxWidth * 0.5) / 3.0;
          final helpButtonHeight = (constraints.maxWidth * 0.4) / 3.0;
          final titleHeight = titleFontSize * 1.0; // タイトルの高さをフォントサイズから推定（行間込み）

          final contentHeight =
              topBandHeight +
              middleBandHeight +
              middleBandToTitleGap +
              titleHeight +
              titleToButtonGap +
              startButtonHeight +
              buttonGap +
              helpButtonHeight +
              bottomGap +
              bottomBandHeight;

          final topFillHeight = ((constraints.maxHeight - contentHeight) / 2).clamp(0.0, constraints.maxHeight);
          final accentOffset = (topFillHeight - accentBandHeight).clamp(0.0, constraints.maxHeight);

          return Stack(
            children: [
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: topFillHeight,
                    child: ColoredBox(
                      color: fillColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: accentOffset,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    height: accentBandHeight,
                    child: ColoredBox(color: accentFillColor),
                  ),
                ),
              ),
              IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: topFillHeight,
                    child: ColoredBox(
                      color: fillColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: accentOffset,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: SizedBox(
                    height: accentBandHeight,
                    child: ColoredBox(color: accentFillColor),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: AppColors.textOnDark,
                    tooltip: AppTexts.goSettings,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DecorativeBand(
                      showBadge: true,
                      badgeIcon: Icons.style,
                      bandHeight: topBandHeight,
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: ColoredBox(
                        color: fillColor, // レイヤーと同じ色
                        child: const SizedBox(height: middleBandHeight), // 帯の太さ
                      ),
                    ),
                    const SizedBox(height: middleBandToTitleGap),
                    Text(
                      AppTexts.gameTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: titleToButtonGap),
                    FractionallySizedBox(
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
                    const SizedBox(height: buttonGap),
                    FractionallySizedBox(
                      widthFactor: 0.4,
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
                    const SizedBox(height: bottomGap),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: ColoredBox(
                        color: fillColor, // レイヤーと同じ色
                        child: const SizedBox(height: middleBandHeight), // 帯の太さ
                      ),
                    ),
                    const DecorativeBand(bandHeight: bottomBandHeight),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}