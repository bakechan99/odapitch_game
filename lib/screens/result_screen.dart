import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../constants/texts.dart';
import '../widgets/custom_confirm_dialog.dart';
import 'settings_screen.dart';
import 'presentation_screen.dart';
import 'voting_screen.dart';
import 'result_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

// 🌟 API通信用のファイルをインポート（パスは環境に合わせて調整してください）
import '../services/api_service.dart';

enum ScreenPhase { presentationStandby, presentation, votingStandby, voting, result }

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;
  const ResultScreen({super.key, required this.players, required this.settings});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ScreenPhase currentPhase = ScreenPhase.presentationStandby;
  int currentPresenterIndex = 0;
  int currentVoterIndex = 0;
  
  Map<int, Map<int, int>> voteMatrix = {};
  Map<int, int> currentAllocation = {};

  // 🌟 AIの採点結果を保存するマップ（key: プレイヤーのIndex, value: AIの点数と講評）
  Map<int, Map<String, dynamic>> aiResults = {};
  // 🌟 AI採点中のローディングフラグ
  bool _isFetchingAI = false;

  Timer? _timer;
  int _timeLeft = 30;
  int _qaTimeLeft = 30; 
  
  bool _isPresentationMode = true; 
  bool _isTimerRunning = false;    

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.players.length; i++) {
      voteMatrix[i] = {};
    }
    setState(() {
      _timeLeft = widget.settings.presentationTimeSec;
      _qaTimeLeft = widget.settings.qaTimeSec;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _showConfirmDialog({required String title, String? content, required VoidCallback onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content ?? "",
        onConfirm: onConfirm,
        cancelText: AppTexts.cancel, 
        confirmText: AppTexts.ok, 
      ),
    );
  }

  void _onHomePressed() {
    _showConfirmDialog(
      title: AppTexts.checkPop,
      content: AppTexts.cautionBackHome,
      onConfirm: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    } else {
      setState(() {
        _isTimerRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        
        setState(() {
          if (_isPresentationMode) {
            if (_timeLeft > 0) {
              _timeLeft--;
            } else {
              _timer?.cancel();
              _isTimerRunning = false;
              _playSound(); 
            }
          } else {
            if (_qaTimeLeft > 0) {
              _qaTimeLeft--;
            } else {
              _timer?.cancel();
              _isTimerRunning = false;
              _playSound(); 
            }
          }
        });
      });
    }
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/timeup.mp3'));
    } catch (e) {
      debugPrint("音声ファイルエラー: $e");
    }
  }

  void _startPresentation() {
    _showConfirmDialog(
      title: AppTexts.presentationStartTitle, 
      content: AppTexts.presentationTimeMsg(widget.settings.presentationTimeSec),
      onConfirm: () {
        setState(() {
          currentPhase = ScreenPhase.presentation;
          _timeLeft = widget.settings.presentationTimeSec;
          _qaTimeLeft = widget.settings.qaTimeSec;
          _isPresentationMode = true;
          _isTimerRunning = false;
        });
      }
    );
  }

  void _proceedToNextStep() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });

    if (_isPresentationMode) {
      setState(() {
        _isPresentationMode = false;
      });
    } else {
      if (currentPresenterIndex < widget.players.length - 1) {
        setState(() {
          currentPresenterIndex++;
          currentPhase = ScreenPhase.presentationStandby;
        });
      } else {
        setState(() {
          currentPhase = ScreenPhase.votingStandby;
        });
      }
    }
  }

  void _startVoting() {
    currentAllocation = {};
    for (int i = 0; i < widget.players.length; i++) {
      if (i != currentVoterIndex) {
        currentAllocation[i] = 0;
      }
    }
    setState(() => currentPhase = ScreenPhase.voting);
  }

  void _submitVote() {
    _showConfirmDialog(
      title: AppTexts.voteConfirmTitle, 
      content: AppTexts.checkBudget,
      onConfirm: () {
        currentAllocation.forEach((targetIndex, amount) {
          voteMatrix[targetIndex]![currentVoterIndex] = amount;
        });

        if (currentVoterIndex < widget.players.length - 1) {
          setState(() {
            currentVoterIndex++;
            currentPhase = ScreenPhase.votingStandby;
          });
        } else {
          _calcResult(); // ここで集計とAI採点に進む！
        }
      }
    );
  }

  // 🌟 変更点：非同期(async)にして、AIに全プレイヤーのタイトルを採点してもらう
  Future<void> _calcResult() async {
    // ローディング画面を表示
    setState(() {
      _isFetchingAI = true;
    });

    // 全プレイヤーのタイトルを順番にAWSに送って採点！
    for (int i = 0; i < widget.players.length; i++) {
      final title = widget.players[i].researchTitle;
      final result = await ApiService.getTitleScore(title);
      
      if (result != null) {
        aiResults[i] = result;
      } else {
        // 万が一通信エラーが起きた場合のダミーデータ
        aiResults[i] = {'score': 0.0, 'feedback': 'AIサーバーと通信できませんでした。'};
      }
    }

    // 採点完了！結果画面へ移行
    setState(() {
      _isFetchingAI = false;
      currentPhase = ScreenPhase.result;
    });

    try {
      //TODO: ここで結果発表の音を鳴らす（音声ファイルは assets/audio/result.mp3 としてプロジェクトに追加しておく）
      //_audioPlayer.play(AssetSource('audio/result.mp3'));
    } catch (e) {
      debugPrint("音声ファイルエラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 変更点：AI採点中はローディング画面を出す
    if (_isFetchingAI) {
      return Scaffold(
        backgroundColor: AppColors.surfacePanel, // 背景色
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppColors.actionAccent),
              SizedBox(height: 20),
              Text(
                'AIが全員のタイトルを厳正に審査中...',
                style: AppTextStyles.headingOnDarkLarge,
              ),
            ],
          ),
        ),
      );
    }

    switch (currentPhase) {
      case ScreenPhase.presentationStandby:
        return _buildStandbyScreen(
          player: widget.players[currentPresenterIndex],
          message: AppTexts.nextPresenter,
          onReady: _startPresentation,
        );
      case ScreenPhase.presentation:
        return PresentationScreen(
          player: widget.players[currentPresenterIndex],
          isPresentationMode: _isPresentationMode,
          isTimerRunning: _isTimerRunning,
          timeLeft: _timeLeft,
          qaTimeLeft: _qaTimeLeft,
          settings: widget.settings,
          onHomePressed: _onHomePressed,
          toggleTimer: _toggleTimer,
          proceedToNextStep: _proceedToNextStep,
        );
      case ScreenPhase.votingStandby:
        return _buildStandbyScreen(
          player: widget.players[currentVoterIndex],
          message: AppTexts.nextVoter,
          onReady: _startVoting,
        );
      case ScreenPhase.voting:
        return VotingScreen(
          players: widget.players,
          currentVoterIndex: currentVoterIndex,
          currentAllocation: currentAllocation,
          onHomePressed: _onHomePressed,
          onAllocationChanged: (index, newVal) {
            setState(() {
              currentAllocation[index] = newVal;
            });
          },
          onIncrement: (index) {
            setState(() {
              int cur = currentAllocation[index] ?? 0;
              if ((currentAllocation.values.fold(0, (s, v) => s + v)) < 100) currentAllocation[index] = cur + 1;
            });
          },
          onDecrement: (index) {
            setState(() {
              int cur = currentAllocation[index] ?? 0;
              if (cur > 0) currentAllocation[index] = cur - 1;
            });
          },
          submitVote: _submitVote,
        );
      case ScreenPhase.result:
        return ResultView(
          players: widget.players,
          voteMatrix: voteMatrix,
          aiResults: aiResults, // 🌟 ここで取得したAIの採点結果を丸ごと渡す！
          getPlayerColor: _getPlayerColor,
          onHomePressed: _onHomePressed,
        );
    }
  }

  Widget _buildStandbyScreen({required Player player, required String message, required VoidCallback onReady}) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
             decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppTexts.nextPlayerStandby(player.name), style: AppTextStyles.headingOnDarkLarge),
                const SizedBox(height: 10),
                Text(message, style: AppTextStyles.bodyOnDarkMedium),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onReady,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: const Text(AppTexts.startVoteButton, style: AppTextStyles.buttonPrimary),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: AppColors.textOnDark,
                tooltip: AppTexts.goSettings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlayerColor(int index) {
    return AppColors.playerPalette[index % AppColors.playerPalette.length];
  }
}