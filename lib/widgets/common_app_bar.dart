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
  static const double _iconTopPadding = 20.0;
  static const double _toolbarHeight = kToolbarHeight + _iconTopPadding+3;

  final String title;
  final VoidCallback onHomePressed;
  final bool showHelp;
  final List<Widget> extraActions;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    required this.title,
    required this.onHomePressed,
    this.showHelp = false,
    this.extraActions = const [],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      backgroundColor: backgroundColor ?? AppColors.themePrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      title: Padding(
        padding: const EdgeInsets.only(top: _iconTopPadding),
        child: Text(title),
      ),
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(top: _iconTopPadding),
        child: IconButton(
          icon: const Icon(Icons.home),
          iconSize: 48,
          onPressed: onHomePressed,
          tooltip: AppTexts.goHome,
        ),
      ),
      actions: [
        ...extraActions,
        if (showHelp)
          Padding(
            padding: const EdgeInsets.only(top: _iconTopPadding),
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              iconSize: 48,
              tooltip: AppTexts.goHelp,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: _iconTopPadding),
          child: IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 48,
            tooltip: AppTexts.goSettings,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
