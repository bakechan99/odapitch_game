import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // APIリクエストのタイムアウト時間を設定（秒）
  static const int fixedTimeoutSec = 30;
  static const Duration requestTimeout = Duration(seconds: fixedTimeoutSec);

  // タイトルを送信して、採点結果をMap（辞書型）で返す関数
  static Future<Map<String, dynamic>?> getTitleScore(String title) async {
    // Androidエミュレータ用のアドレス
    final url = Uri.parse('https://dxaulrcbi7apve2f6ndyzuaviu0jdisf.lambda-url.ap-northeast-1.on.aws/title_score');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // ここで academic モードを指定！
        body: jsonEncode({'title': title, 'mode': 'academic'}),
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        // 成功したら、スコアとフィードバックの入ったデータを返す
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('エラー: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('タイムアウト: $e');
      return null;
    } catch (e) {
      print('通信エラー: $e');
      return null;
    }
  }
}