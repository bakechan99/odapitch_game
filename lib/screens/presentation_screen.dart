import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import '../widgets/common_app_bar.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PresentationScreen extends StatelessWidget {
  final Player player;
  final bool isPresentationMode;
  final bool isTimerRunning;
  final int timeLeft;
  final int qaTimeLeft;
  final GameSettings settings;
  final VoidCallback onHomePressed;
  final VoidCallback toggleTimer;
  final VoidCallback proceedToNextStep;
  final VoidCallback onResetTimer;
  final bool isLastPresenter;
  final String odaiTheme;

  const PresentationScreen({
    super.key,
    required this.player,
    required this.isPresentationMode,
    required this.isTimerRunning,
    required this.timeLeft,
    required this.qaTimeLeft,
    required this.settings,
    required this.onHomePressed,
    required this.toggleTimer,
    required this.proceedToNextStep,
    required this.onResetTimer,
    this.isLastPresenter = false,
    this.odaiTheme = '',
  });

  @override
  Widget build(BuildContext context) {
    final int activeTime = isPresentationMode ? timeLeft : qaTimeLeft;

    final String timerLabel = isPresentationMode
        ? AppTexts.presentationTimerLabel
        : AppTexts.qaTimerLabel;
    final String goNextText = isPresentationMode
        ? AppTexts.goFeedback
        : (isLastPresenter ? AppTexts.goToVoting : AppTexts.goToQa);

    final Color backgroundColor = isPresentationMode 
        ? AppColors.themePrimary
        : AppColors.themePrimaryDark;

    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: CommonAppBar(
        title: "",
        backgroundColor: backgroundColor,
        onHomePressed: onHomePressed,
      ),
      body: Container(
        decoration:BoxDecoration(
          image: DecorationImage(
            image: isPresentationMode
              ? AssetImage('assets/images/GND_presentation.png')
              : AssetImage('assets/images/GND_presentation_2.png'),
            fit: BoxFit.cover
          ),
        ),
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- お題エリア ---
              if (odaiTheme.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppTexts.odaitheme(odaiTheme),
                    style: AppTextStyles.headingSection.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              // --- タイマーカード ---
              Container(
                width: 400,
                height: 160,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      timerLabel, 
                      style: AppTextStyles.headingPrimaryLarge
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // リセットボタン
                        IconButton(
                          icon: const Icon(Icons.replay),
                          iconSize: 56,
                          color: AppColors.textPrimary,
                          onPressed: onResetTimer,
                          tooltip: "リセット",
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:Center(
                            child: SizedBox(
                              width: 240,
                              child: Center(
                                child: Text(
                                  AppTexts.timerFormat(activeTime),
                                  style: AppTextStyles.timeValue.copyWith(
                                    fontSize: 48,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          )
                        ),
                        // 再生/一時停止ボタン
                        IconButton(
                          icon: Icon(
                            isTimerRunning
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_outline,
                          ),
                          iconSize: 56,
                          color: AppColors.textPrimary,
                          onPressed: toggleTimer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // --- 研究タイトルエリア ---
              Expanded(
                child: Container(
                  width: 400,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: isPresentationMode
                          ? AssetImage('assets/images/presentation_background.png')
                          : AssetImage('assets/images/question_background.png'), 
                       //fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 60, left: 40, right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 吹き出し上部の余白
                        const SizedBox(height: 88),
                        // タイトルを吹き出しコンテナ内の中央に配置
                        Expanded(
                          child: Center(
                            child: AutoSizeText(
                              player.researchTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.valueDisplayLarge,
                              maxLines: 3,
                              minFontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
              ),
              // --- バナー（矢印形状） ---
              Center(
                child:GestureDetector(
                  onTap: proceedToNextStep,
                  child: CustomPaint(
                    painter: ArrowShadowPainter(arrowDepth: 28),
                    child: ClipPath(
                      clipper: ArrowClipper(),
                      child: Container(
                          width: 400,
                          height: 60,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15

                            ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                          ),
                          child: Text(
                            goNextText,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonPrimaryBold.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// 矢印形状の影を描くPainter
class ArrowShadowPainter extends CustomPainter {
  final double arrowDepth;
  ArrowShadowPainter({this.arrowDepth = 28});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowDepth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowDepth, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, Colors.black38, 6, true);
  }

  @override
  bool shouldRepaint(ArrowShadowPainter oldDelegate) =>
      oldDelegate.arrowDepth != arrowDepth;
}

/// 右側が矢印（▶）の形状になるClipper
class ArrowClipper extends CustomClipper<Path> {
  final double arrowDepth;
  ArrowClipper({this.arrowDepth = 28});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowDepth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowDepth, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ArrowClipper oldClipper) => oldClipper.arrowDepth != arrowDepth;
}
