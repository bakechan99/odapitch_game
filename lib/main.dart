import 'package:flutter/material.dart';
import 'screens/title_screen.dart'; // 設定画面を呼び出す

void main() {
  runApp(const KakenhiGameApp());
}

class KakenhiGameApp extends StatelessWidget {
  const KakenhiGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カケンヒゲーム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TitleScreen(), // ここで最初の画面を指定
    );
  }
}

// 互換性のためのエイリアスクラス: テストなどで `MyApp` を参照している箇所に対応
class MyApp extends KakenhiGameApp {
  const MyApp({super.key});
}