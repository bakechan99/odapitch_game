import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/title_screen.dart'; // 設定画面を呼び出す
import 'constants/texts.dart';
import 'constants/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; 

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // デスクトップ環境で sqflite を初期化
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await MobileAds.instance.initialize(); // Google Mobile Ads SDK の初期化
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

// 互換性のためのエイリアスクラス: テストなどで `MyApp` を参照している箇所に対応
class MyApp extends KakenhiGameApp {
  const MyApp({super.key});
}