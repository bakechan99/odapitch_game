import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/texts.dart';
import '../constants/app_text_styles.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themePrimary,
      appBar: AppBar(
        title: Text(
          AppTexts.helpTitle,
          style: AppTextStyles.titleButton.copyWith(
            fontSize: 40,
            color: AppColors.textPrimary,
          ),
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
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/tutorial_1.svg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 16),
              SvgPicture.asset(
                'assets/images/tutorial_2.svg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 16),
              SvgPicture.asset(
                'assets/images/tutorial_3.svg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 16),
              SvgPicture.asset(
                'assets/images/tutorial_4.svg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 16),
              SvgPicture.asset(
                'assets/images/tutorial_5.svg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
