import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';

/// 共通AppBar
///
/// - [title] : AppBarのタイトル文字列
/// - [onHomePressed] : ホームボタン押下時のコールバック
/// - [showHelp] : ヘルプボタンを表示するか（デフォルト false）
/// - [extraActions] : 追加のアクションボタン（オプション）
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onHomePressed;
  final bool showHelp;
  final List<Widget> extraActions;

  const CommonAppBar({
    super.key,
    required this.title,
    required this.onHomePressed,
    this.showHelp = false,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceTheme,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.home),
        iconSize: 30,
        onPressed: onHomePressed,
        tooltip: AppTexts.goHome,
      ),
      actions: [
        ...extraActions,
        if (showHelp)
          IconButton(
            icon: const Icon(Icons.help_outline),
            iconSize: 30,
            tooltip: AppTexts.goHelp,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          iconSize: 30,
          tooltip: AppTexts.goSettings,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
