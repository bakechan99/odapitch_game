import 'package:flutter/material.dart';
import 'screens/setup_screen.dart'; // 設定画面を呼び出す

void main() {
  runApp(const KakenhiGameApp());
}

class KakenhiGameApp extends StatelessWidget {
  const KakenhiGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '科研費ゲーム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SetupScreen(), // ここで最初の画面を指定
    );
  }
}