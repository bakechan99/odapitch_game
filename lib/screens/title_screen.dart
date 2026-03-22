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
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }

  /// 利用規約・プライバシーポリシーの両リンクをボトムシートで表示する。
  void _showLegalMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                AppTexts.legalMenuTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text(AppTexts.goTerms),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                Navigator.pop(sheetContext);
                _openUrl(AppTexts.termsUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: const Text(AppTexts.goPrivacyPolicy),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                Navigator.pop(sheetContext);
                _openUrl(AppTexts.privacyPolicyUrl);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
                              icon: const Icon(Icons.policy_outlined),
                              iconSize: 48,
                              color: AppColors.textOnDark,
                              tooltip: AppTexts.legalMenuTitle,
                              onPressed: _showLegalMenu,
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