import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/texts.dart';
import '../utils/consent_manager.dart';
import 'title_screen.dart';

/// 初回起動時に表示する利用規約・プライバシーポリシー同意画面。
/// 同意せずに進む手段は存在しない（アプリを終了するしかない）。
class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }

  Future<void> _onAgree(BuildContext context) async {
    await ConsentManager.setAccepted();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TitleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像：横幅に合わせて自然に縮尺
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/GND_title_up.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          // コンテンツ
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // アプリ名
                        Text(
                          AppTexts.appTitle,
                          style: AppTextStyles.headingPrimaryLarge.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 説明文
                        Text(
                          AppTexts.consentDescription,
                          textAlign: TextAlign.justify,
                          style: AppTextStyles.bodyMuted.copyWith(
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 利用規約リンク
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text(AppTexts.goTerms),
                            onPressed: () =>
                                _openUrl(context, AppTexts.termsUrl),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // プライバシーポリシーリンク
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text(AppTexts.goPrivacyPolicy),
                            onPressed: () =>
                                _openUrl(context, AppTexts.privacyPolicyUrl),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 同意ボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _onAgree(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.themePrimaryDark,
                              foregroundColor: AppColors.textOnDark,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppTexts.consentAgreeButton,
                              style: AppTextStyles.headingPrimaryMedium
                                  .copyWith(color: AppColors.textOnDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
