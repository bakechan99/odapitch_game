import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/texts.dart';
import '../widgets/passing_style_card.dart';
import '../widgets/custom_banner_ad.dart';

class PassingConfirmScreen extends StatelessWidget {
  final String title;
  final String content;

  const PassingConfirmScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppColors.surfaceTheme),
          Center(
            child: PassingStyleCard(
              title: title,
              content: content,
              primaryButtonText: AppTexts.ok,
              onPrimaryPressed: () => Navigator.of(context).pop(true),
              secondaryButtonText: AppTexts.cancel,
              onSecondaryPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const CustomBannerAd(),
        ],
      ),
    );
  }
}
