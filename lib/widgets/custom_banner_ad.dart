import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // OSごとにGoogle公式のテスト用バナーIDを設定
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // AndroidテストID
      : 'ca-app-pub-3940256099942544/2934735716'; // iOSテストID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // 標準的なバナーサイズ（320x50）
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('バナー広告の読み込みに失敗しました: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // 画面が消える時にメモリを解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!), // 🌟 ここで広告を表示！
          ),
        ),
      );
    }
    // 読み込み中や失敗時は空のスペース（またはグレーの枠）を返す
    return const SizedBox(height: 50); 
  }
}