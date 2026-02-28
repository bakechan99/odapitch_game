import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/player.dart';

enum ScreenPhase { presentationStandby, presentation, votingStandby, voting, result }

typedef TitleScorer = Future<Map<String, dynamic>?> Function(String title);
typedef TimeUpCallback = Future<void> Function();

class ResultSessionController extends ChangeNotifier {
  // AIスコアが取得できなかった場合のスコア倍率
  static const double fixedFailedAiMultiplier = 1.0;

  ResultSessionController({
    required this.players,
    required this.presentationTimeSec,
    required this.qaTimeSec,
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

  Future<void> calcResult() async {
    isFetchingAI = true;
    notifyListeners();

    for (int index = 0; index < players.length; index++) {
      final title = players[index].researchTitle;
      final result = await titleScorer(title);
      if (result != null) {
        aiResults[index] = result;
      } else {
        aiResults[index] = {
          'score': fixedFailedAiMultiplier,
          'feedback': 'AIサーバーと通信できませんでした。',
          'isFallback': true,
        };
      }
    }

    isFetchingAI = false;
    currentPhase = ScreenPhase.result;
    notifyListeners();
  }

  void setAllocation(int index, int newValue) {
    currentAllocation[index] = newValue;
    notifyListeners();
  }

  void incrementAllocation(int index) {
    final current = currentAllocation[index] ?? 0;
    final total = currentAllocation.values.fold(0, (sum, value) => sum + value);
    if (total < 100) {
      currentAllocation[index] = current + 1;
      notifyListeners();
    }
  }

  void decrementAllocation(int index) {
    final current = currentAllocation[index] ?? 0;
    if (current > 0) {
      currentAllocation[index] = current - 1;
      notifyListeners();
    }
  }
}
