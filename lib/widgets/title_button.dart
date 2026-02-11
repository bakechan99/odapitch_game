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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン部分
            // ※本来はご提示の画像を切り出してアセットとして使うのがベストです。
            // ここでは標準アイコンを組み合わせて雰囲気を再現しています。
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
                  child: Icon(Icons.menu_book, color: AppColors.titleButtonText, size: 22),
                ),
                Transform.translate(
                  offset: const Offset(4, -4),
                  child: Transform.rotate(
                    angle: -0.5, // ロケットを少し傾ける
                    child: Icon(Icons.rocket, color: AppColors.titleButtonText, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // テキスト部分
            Text(
              widget.label,
              style: AppTextStyles.titleButton,
            ),
          ],
        ),
      ),
    );
  }
}