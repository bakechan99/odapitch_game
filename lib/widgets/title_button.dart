import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TitleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const TitleButton({
    Key? key,
    required this.onPressed,
    this.label = AppTexts.startGameButton,
  }) : super(key: key);

  @override
  _TitleButtonState createState() => _TitleButtonState();
}

class _TitleButtonState extends State<TitleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // タップ時の状態を管理
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        // 押された時に少し沈むように見せるマージン調整
        margin: EdgeInsets.only(top: _isPressed ? 4.0 : 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          // 角丸の設定
          borderRadius: BorderRadius.circular(30),
          // 背景色：立体感を出すための微妙なグラデーション
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [AppColors.titleButtonPressedTop, AppColors.titleButtonPressedBottom] // 押下時（少し暗く）
                : [AppColors.titleButtonNormalTop, AppColors.titleButtonNormalBottom], // 通常時（上から光）
          ),
          // 外側の枠線
          border: Border.all(
            color: AppColors.titleButtonBorder,
            width: 2.5,
          ),
          // 影と内側のハイライト（二重枠のような表現）
          boxShadow: _isPressed
              ? [] // 押下時は影をなくして沈んだように見せる
              : [
                  // ボタンの下の柔らかい影
                  const BoxShadow(
                    color: AppColors.titleButtonShadow,
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                  // 内側上部のハイライト（立体感の強調）
                  BoxShadow(
                    color: AppColors.titleButtonInnerHighlight.withOpacity(0.4),
                    offset: const Offset(0, 1),
                    blurRadius: 0,
                    spreadRadius: -1, // 内側に影を入れるテクニック
                  )
                ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleButton,
            ),
          )
        ),
      ),
    );
  }
}