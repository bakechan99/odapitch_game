import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/player.dart';

enum ScreenPhase {
  presentationStandby,
  presentation,
  votingStandby,
  voting,
  result,
}

typedef TitleScorer = Future<Map<String, dynamic>?> Function(String title);
typedef TimeUpCallback = Future<void> Function();

class ResultSessionController extends ChangeNotifier {
  // AIスコアが取得できなかった場合のスコア倍率
  static const double fixedFailedAiMultiplier = 1.0;

  ResultSessionController({
    required this.players,
    required this.presentationTimeSec,
    required this.qaTimeSec,
    required this.isAiEnabled, // 追加
    required this.titleScorer,
    required this.onTimeUp,
  }) {
    for (int index = 0; index < players.length; index++) {
      voteMatrix[index] = {};
    }

    _timeLeft = presentationTimeSec;
    _qaTimeLeft = qaTimeSec;
  }

  final List<Player> players;
  final int presentationTimeSec;
  final int qaTimeSec;
  final bool isAiEnabled; // 追加
  final TitleScorer titleScorer;
  final TimeUpCallback onTimeUp;

  ScreenPhase currentPhase = ScreenPhase.presentationStandby;
  int currentPresenterIndex = 0;
  int currentVoterIndex = 0;

  final Map<int, Map<int, int>> voteMatrix = {};
  final Map<int, int> currentAllocation = {};
  final Map<int, Map<String, dynamic>> aiResults = {};

  bool isFetchingAI = false;
  bool isPresentationMode = true;
  bool isTimerRunning = false;

  Timer? _timer;
  int _timeLeft = 30;
  int _qaTimeLeft = 30;

  int get timeLeft => _timeLeft;
  int get qaTimeLeft => _qaTimeLeft;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startPresentation() {
    _timer?.cancel();
    currentPhase = ScreenPhase.presentation;
    _timeLeft = presentationTimeSec;
    _qaTimeLeft = qaTimeSec;
    isPresentationMode = true;
    isTimerRunning = false;
    notifyListeners();
  }

  void toggleTimer() {
    if (isTimerRunning) {
      _timer?.cancel();
      isTimerRunning = false;
      notifyListeners();
      return;
    }

    isTimerRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isPresentationMode) {
        if (_timeLeft > 0) {
          _timeLeft--;
          notifyListeners();
          return;
        }
      } else {
        if (_qaTimeLeft > 0) {
          _qaTimeLeft--;
          notifyListeners();
          return;
        }
      }

      _timer?.cancel();
      isTimerRunning = false;
      notifyListeners();
      await onTimeUp();
    });
  }

  void resetTimer() {
    _timer?.cancel();
    isTimerRunning = false;
    if (isPresentationMode) {
      _timeLeft = presentationTimeSec;
    } else {
      _qaTimeLeft = qaTimeSec;
    }
    notifyListeners();
  }

  void proceedToNextStep() {
    _timer?.cancel();
    isTimerRunning = false;

    if (isPresentationMode) {
      isPresentationMode = false;
      notifyListeners();
      return;
    }

    if (currentPresenterIndex < players.length - 1) {
      currentPresenterIndex++;
      currentPhase = ScreenPhase.presentationStandby;
    } else {
      currentPhase = ScreenPhase.votingStandby;
    }

    notifyListeners();
  }

  void startVoting() {
    currentAllocation.clear();
    for (int index = 0; index < players.length; index++) {
      if (index != currentVoterIndex) {
        currentAllocation[index] = 0;
      }
    }

    currentPhase = ScreenPhase.voting;
    notifyListeners();
  }

  Future<void> submitVote() async {
    currentAllocation.forEach((targetIndex, amount) {
      voteMatrix[targetIndex]![currentVoterIndex] = amount;
    });

    if (currentVoterIndex < players.length - 1) {
      currentVoterIndex++;
      currentPhase = ScreenPhase.votingStandby;
      notifyListeners();
      return;
    }

    await calcResult();
  }

  /// AI採点または集計を実行する
  Future<void> calcResult() async {
    isFetchingAI = true;
    notifyListeners(); // ローディング開始をUIに通知

    try {
      if (isAiEnabled) {
        // AIが有効な場合：各プレイヤーのタイトルをAPIに送信
        for (int index = 0; index < players.length; index++) {
          final title = players[index].researchTitle;

          // 1人目以外のリクエスト前に1秒のインターバルを置く（レート制限対策）
          if (index > 0) {
            debugPrint(
              'Waiting 1 second before next request (Scoring for Player $index)...',
            );
            await Future.delayed(const Duration(seconds: 1));
          }

          try {
            debugPrint('Requesting AI score for: $title');

            // 順番に1人ずつリクエストを送信
            final result = await titleScorer(
              title,
            ).timeout(const Duration(seconds: 30));

            if (result != null) {
              aiResults[index] = result;
              debugPrint('Success: AI Score received for Player $index');
            } else {
              throw Exception("Null response from API");
            }
          } catch (e) {
            // エラー（502, タイムアウト等）が発生してもループを止めない
            debugPrint("AI Scoring Error for Player $index: $e");
            aiResults[index] = {
              'score': 1.0, // フォールバック：スコア倍率1.0
              'feedback': 'サーバー混雑のため、AI採点に失敗しました。標準スコアで集計します。',
              'isFallback': true,
            };
          }
        }
      } else {
        // ... (AI無効時の処理は変更なし)
        for (int index = 0; index < players.length; index++) {
          aiResults[index] = {
            'score': 1.0,
            'feedback': 'AI採点はオフに設定されています。',
            'isAiDisabled': true,
          };
        }
      }
    } catch (globalError) {
      debugPrint("Critical Error in calcResult: $globalError");
    } finally {
      isFetchingAI = false;
      currentPhase = ScreenPhase.result;
      notifyListeners(); // UIを結果表示へ
    }
  }

  // --- 投票ロジックの続き ---
  void setAllocation(int index, int newValue) {
    currentAllocation[index] = newValue;
    notifyListeners();
  }

  void incrementAllocation(int index) {
    final current = currentAllocation[index] ?? 0;
    final total = currentAllocation.values.fold(0, (sum, value) => sum + value);
    if (total < 100) {
      currentAllocation[index] = current + 10;
      notifyListeners();
    }
  }

  void decrementAllocation(int index) {
    final current = currentAllocation[index] ?? 0;
    if (current > 0) {
      currentAllocation[index] = current - 10;
      notifyListeners();
    }
  }
} // クラスの閉じ括弧
