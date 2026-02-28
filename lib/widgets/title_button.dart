import 'package:flutter/material.dart';
import '../constants/texts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TitleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Color borderColor;
  final Color fillColor;
  final Color textColor;

  const TitleButton({
    super.key,
    required this.onPressed,
    this.label = AppTexts.startGameButton,
    this.borderColor = AppColors.titleButtonBorder,
    this.fillColor = AppColors.titleButtonNormalTop,
    this.textColor = AppColors.titleButtonText,
  });

  @override
  _TitleButtonState createState() => _TitleButtonState();
}

class _TitleButtonState extends State<TitleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final pressedColor = HSLColor.fromColor(widget.fillColor)
        .withLightness((HSLColor.fromColor(widget.fillColor).lightness - 0.08).clamp(0.0, 1.0))
        .toColor();

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
          color: _isPressed ? pressedColor : widget.fillColor,
          // 外側の枠線
          border: Border.all(
            color: widget.borderColor,
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
                ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleButton.copyWith(color: widget.textColor),
            ),
          )
        ),
      ),
    );
  }
}