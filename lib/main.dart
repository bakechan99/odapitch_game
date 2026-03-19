import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb用
import 'dart:io'; // Platform用
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // FFI初期化用
import 'package:sqflite/sqflite.dart'; // databaseFactory設定用

import 'screens/title_screen.dart'; // 設定画面を呼び出す
import 'constants/texts.dart';
import 'constants/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 必須

  // ▼ ここから：追加するFFIの初期化コード ▼
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // ▲ ここまで ▲

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          toolbarHeight: 72,
          backgroundColor: AppColors.themePrimary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: AppColors.transparent,
        ),
        primarySwatch: AppColors.primarySwatch,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TitleScreen(), // ここで最初の画面を指定
    );
  }
}
