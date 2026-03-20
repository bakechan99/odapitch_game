import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // APIリクエストのタイムアウト時間を設定（秒）
  static const int fixedTimeoutSec = 30;
  static const Duration requestTimeout = Duration(seconds: fixedTimeoutSec);

  // タイトルを送信して、指定されたお題（mode）に基づいて採点結果をMap（辞書型）で返す関数
  static Future<Map<String, dynamic>?> getTitleScore(
    String title, {
    String mode = 'academic',
  }) async {
    final url = Uri.parse(
      'https://dxaulrcbi7apve2f6ndyzuaviu0jdisf.lambda-url.ap-northeast-1.on.aws/title-score',
    );

    // 送信データの作成
    final Map<String, String> requestBody = {'title': title, 'mode': mode};
    final String encodedBody = jsonEncode(requestBody);

    // 【ログ】送信データの中身を出力
    debugPrint('--- AI API Request ---');
    debugPrint('URL: $url');
    debugPrint('Body: $encodedBody');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: encodedBody,
          )
          .timeout(requestTimeout);

      // 【ログ】レスポンスの詳細を出力
      debugPrint('--- AI API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('Server Error: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (e) {
      debugPrint('API Timeout: $e');
      return null;
    } catch (e) {
      // 【ログ】通信エラーの具体的な内容を出力
      debugPrint('API Error: $e');
      return null;
    }
  }
}
