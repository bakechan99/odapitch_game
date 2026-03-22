import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb用
import 'dart:io'; // Platform用
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // FFI初期化用
import 'package:sqflite/sqflite.dart'; // databaseFactory設定用

import 'screens/title_screen.dart';
import 'screens/consent_screen.dart';
import 'constants/texts.dart';
import 'constants/app_colors.dart';
import 'utils/consent_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 必須

  // ▼ ここから：追加するFFIの初期化コード ▼
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // ▲ ここまで ▲

  // AdMob SDK初期化（iOS / Android のみ）
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

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
      home: const _ConsentGate(),
    );
  }
}

/// 起動時に同意状態をチェックし、未同意なら ConsentScreen へ、
/// 同意済みなら TitleScreen へ振り分けるゲートウィジェット。
class _ConsentGate extends StatelessWidget {
  const _ConsentGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ConsentManager.hasAccepted(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 同意状態を確認中はスプラッシュ的なローディングを表示
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const TitleScreen() : const ConsentScreen();
      },
    );
  }
}
