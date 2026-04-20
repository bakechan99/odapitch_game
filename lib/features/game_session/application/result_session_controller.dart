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

// 全プレイヤー分のデータを一括送信して採点結果を受け取るコールバック型
typedef BatchTitleScorer = Future<Map<String, dynamic>?> Function(
  List<Map<String, String>> players,
);
// isPresentationMode: true=発表タイマー終了, false=質疑応答タイマー終了
typedef TimeUpCallback = Future<void> Function(bool isPresentationMode);

class ResultSessionController extends ChangeNotifier {
  // AIスコアが取得できなかった場合のスコア倍率
  static const double fixedFailedAiMultiplier = 1.0;

  ResultSessionController({
    required this.players,
    required this.presentationTimeSec,
    required this.qaTimeSec,
    required this.isAiEnabled,
    required this.batchScorer,
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
  final bool isAiEnabled;
  final BatchTitleScorer batchScorer;
  final TimeUpCallback onTimeUp;

  ScreenPhase currentPhase = ScreenPhase.presentationStandby;
  int currentPresenterIndex = 0;
  int currentVoterIndex = 0;

  final Map<int, Map<int, int>> voteMatrix = {};
  final Map<int, int> currentAllocation = {};
  final Map<int, Map<String, dynamic>> aiResults = {};

  // 全体の総評（一括評価で取得）
  String? overallReview;

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
      await onTimeUp(isPresentationMode);
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

    // UIのリビルドをイベントループに処理させてからAPI呼び出しを行う。
    // これを省くと、notifyListeners()後の同期コードがフレーム描画の前に
    // 実行され、ローディング画面が表示されないままフリーズしたように見える。
    await Future.delayed(Duration.zero);

    try {
      if (isAiEnabled) {
        // 全プレイヤーのデータを一括送信
        final playersData = players
            .map((p) => {'name': p.name, 'title': p.researchTitle})
            .toList();
        debugPrint('Requesting batch AI score for ${players.length} players...');

        try {
          final result = await batchScorer(playersData)
              .timeout(const Duration(seconds: 60));

          if (result != null) {
            // 全体の総評を保存
            overallReview = result['overall_review'] as String?;
            debugPrint('Overall review: $overallReview');

            // scoresリストをプレイヤー名で突合して各Playerに代入
            final scores = result['scores'] as List<dynamic>? ?? [];
            for (int index = 0; index < players.length; index++) {
              final playerName = players[index].name;
              final scoreData = scores.firstWhere(
                (s) => s['player_name'] == playerName,
                orElse: () => null,
              );

              if (scoreData != null) {
                final score = (scoreData['score'] as num).toDouble();
                final comment = scoreData['comment'] as String? ?? '';
                players[index].aiScore = score;
                players[index].aiFeedback = comment;
                aiResults[index] = {'score': score, 'feedback': comment};
                debugPrint('Player $playerName: score=$score');
              } else {
                debugPrint('Score data not found for: $playerName');
                players[index].aiScore = 1.0;
                players[index].aiFeedback = 'AI採点データが見つかりませんでした。';
                aiResults[index] = {
                  'score': 1.0,
                  'feedback': 'AI採点データが見つかりませんでした。',
                  'isFallback': true,
                };
              }
            }
          } else {
            throw Exception("Null response from batch API");
          }
        } catch (e) {
          debugPrint("Batch AI Scoring Error: $e");
          // エラー時は全プレイヤーをフォールバック
          overallReview = 'サーバー混雑のため、AI採点に失敗しました。';
          for (int index = 0; index < players.length; index++) {
            players[index].aiScore = 1.0;
            players[index].aiFeedback = 'サーバー混雑のため、AI採点に失敗しました。標準スコアで集計します。';
            aiResults[index] = {
              'score': 1.0,
              'feedback': 'サーバー混雑のため、AI採点に失敗しました。標準スコアで集計します。',
              'isFallback': true,
            };
          }
        }
      } else {
        // AI無効時の処理（変更なし）
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
