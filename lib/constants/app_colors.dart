import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Theme palette
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color themePrimary = Colors.blue;
  static const Color themeAccent = Colors.blueAccent;

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textStrong = Colors.black;
  static const Color textSecondary = Colors.black54;
  static const Color textMuted = Colors.grey;
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMuted = Colors.white70;
  static const Color textAccent = Colors.blue;
  static const Color textTitle = Colors.black87;
  static Color get textAccentStrong => Colors.blue.shade800;
  static Color get textPlaceholder => Colors.grey.shade400;

  // Backgrounds
  static const Color surface = Colors.white;
  static Color get surfaceMuted => Colors.grey.shade100;
  static Color get surfaceSubtle => Colors.grey.shade200;
  static Color get surfacePanel => Colors.blueGrey.shade50;
  static const Color overlayScrim = Colors.black;
  static const Color transparent = Colors.transparent;

  // Actions
  static const Color actionPrimary = Colors.blue;
  static const Color actionAccent = Colors.orange;
  static const Color actionDanger = Colors.red;
  static const Color actionDisabled = Colors.grey;
  static const Color actionNeutral = Colors.grey;

  // Buttons (dialog / custom)
  static const Color dialogSurface = Color.fromARGB(255, 231, 231, 231);
  static const Color dialogBorder = Color.fromARGB(255, 105, 105, 105);
  static Color get dialogIcon => Colors.grey.shade600;
  static const Color dialogConfirmBg = Colors.grey;
  static Color get dialogConfirmBgStrong => Colors.grey.shade800;
  static Color get dialogCancelText => Colors.grey.shade600;

  static const Color fancyButtonDefault = Colors.blue;
  static const Color fancyButtonDisabled = Colors.grey;
  static Color get fancyButtonDisabledLight => Colors.grey.shade400;

  // Borders / dividers / shadows
  static const Color borderAccent = Colors.blueAccent;
  static Color get borderLight => Colors.grey.shade300;
  static Color get divider => Colors.grey.shade200;
  static Color get dividerStrong => Colors.grey.shade300;
  static const Color shadowLight = Colors.black12;
  static const Color shadowBase = Colors.black;
  static const Color shadowMuted = Colors.grey;

  // Section / highlight
  static const Color sectionTitle = Colors.blueGrey;
  static Color get selectionHighlight => Colors.yellow.shade100;

  // Gradient helpers
  static const Color gradientStart = Colors.blueGrey;
  static const Color gradientEnd = Colors.black87;

  // Player palette
  static const List<Color> playerPalette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  static const Color titleButtonBorder = Color(0xFF757575);
  static const Color titleButtonText = Color(0xFF424242);
  static const Color titleButtonShadow = Colors.black26;
  static const Color titleButtonPressedTop = Color(0xFF9E9E9E);
  static const Color titleButtonPressedBottom = Color(0xFFBDBDBD);
  static const Color titleButtonNormalTop = Color(0xFFE0E0E0);
  static const Color titleButtonNormalBottom = Color(0xFFBDBDBD);
  static const Color titleButtonInnerHighlight = Colors.white;

  static const Color cardBackground = surface;
  static const Color iconMuted = textMuted;


}
