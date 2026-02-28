import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // Section headers
  static const TextStyle headingSection = 
  TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.sectionTitle,
  );

  static const TextStyle headingSectionLarge = 
  TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.sectionTitle,
  );

  static const TextStyle headingPrimaryLarge = 
  TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingPrimaryMedium = 
  TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingOnDarkLarge = 
  TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );

  static const TextStyle headingOnDarkMedium = 
  TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );

  // Labels
  static const TextStyle labelField = 
  TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMutedBold = 
  TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
  );

  static const TextStyle labelMutedSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle labelAccentBold = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.textAccent,
  );

  static const TextStyle labelBold = TextStyle(
    fontWeight: FontWeight.bold,
  );

  // Values
  static const TextStyle valueLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle valueDisplayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle valueDisplayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle valueDisplayMuted = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  // Buttons
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonPrimaryBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 18,
  );

  static const TextStyle buttonMediumBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 16,
  );

  static const TextStyle buttonLabelBold = TextStyle(
    fontWeight: FontWeight.bold,
  );

  // Title button
  static final TextStyle titleButton =  GoogleFonts.delaGothicOne(
    color: AppColors.titleButtonText,
    fontSize: 100,
    fontWeight: FontWeight.w700,
  );

  // Dialog
  static const TextStyle dialogTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle dialogBody = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Fancy button
  static const TextStyle fancyButtonLabel = TextStyle(
    color: AppColors.textOnDark,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Card text
  static const TextStyle cardTextSelected = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textStrong,
  );

  static const TextStyle cardTextUnselected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const TextStyle cardHandText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body text
  static const TextStyle bodyMuted = TextStyle(
    color: AppColors.textMuted,
  );

  static const TextStyle bodyOnDarkSmall = TextStyle(
    color: AppColors.textOnDarkMuted,
  );

  static const TextStyle bodyOnDarkMedium = TextStyle(
    fontSize: 18,
    color: AppColors.textOnDarkMuted,
  );

  static final TextStyle bodyPlaceholder = TextStyle(
    fontSize: 16,
    color: AppColors.textPlaceholder,
  );

  // Result/ranking
  static const TextStyle rankEmoji = TextStyle(fontSize: 24);

  static const TextStyle playerName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(fontSize: 12);

  static const TextStyle captionMuted = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle amountTotal = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.themeAccent,
  );

  static const TextStyle amountAccent = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textAccent,
  );

  static const TextStyle amountTinyOnDark = TextStyle(
    color: AppColors.textOnDark,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  // Legacy aliases (avoid for new code)
  static const TextStyle sectionTitle = headingSection;
  static const TextStyle sliderLabel = labelField;
  static const TextStyle sliderValue = valueLarge;
  static const TextStyle primaryButton = buttonPrimary;
  static final TextStyle titleButtonLabel = titleButton;
}
