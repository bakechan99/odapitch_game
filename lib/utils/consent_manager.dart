import 'package:shared_preferences/shared_preferences.dart';

/// 利用規約・プライバシーポリシーへの同意状態を管理するクラス。
/// SharedPreferences にフラグを保存し、初回起動時の同意フローを制御する。
class ConsentManager {
  ConsentManager._();

  static const String _keyConsentAccepted = 'consent_accepted';

  /// ユーザーが既に同意済みかどうかを返す。
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsentAccepted) ?? false;
  }

  /// 同意済みとしてフラグを保存する。
  static Future<void> setAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConsentAccepted, true);
  }
}
