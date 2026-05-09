import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdManager {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  // Google 公式テスト用広告ユニットID
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-1863882102807550/5421180469';

  bool get isLoaded => _isLoaded;

  /// 広告をロードする
  void loadAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded.');
          _rewardedAd = ad;
          _isLoaded = true;

          // フルスクリーンコンテンツのコールバックを設定
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Ad dismissed.');
              ad.dispose();
              _isLoaded = false;
              loadAd(); // 次回のために再ロード
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Ad failed to show: $error');
              ad.dispose();
              _isLoaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  /// 広告を表示する
  void showAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdClosed,
  }) {
    if (_rewardedAd == null || !_isLoaded) {
      debugPrint('Warning: Attempted to show ad before it was loaded.');
      onAdClosed(); // ロードされていない場合はそのまま次へ進める
      return;
    }

    bool rewarded = false;

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        rewarded = true;
      },
    );

    // 広告終了時の処理を上書きしてコールバックを実行
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isLoaded = false;
        loadAd(); // 再ロード
        if (rewarded) {
          onRewardEarned();
        } else {
          onAdClosed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isLoaded = false;
        loadAd();
        onAdClosed(); // エラー時はフォールバック
      },
    );
  }
}
