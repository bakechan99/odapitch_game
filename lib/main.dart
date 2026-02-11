import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/title_screen.dart'; // 設定画面を呼び出す
import 'constants/texts.dart';
import 'constants/app_colors.dart';

void main() {
  // デスクトップ環境で sqflite を初期化
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const KakenhiGameApp());
}

class KakenhiGameApp extends StatelessWidget {
  const KakenhiGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
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