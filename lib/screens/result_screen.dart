import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../constants/texts.dart';
import '../widgets/custom_confirm_dialog.dart'; // 追加
import 'settings_screen.dart';
import 'presentation_screen.dart';
import 'voting_screen.dart';
import 'result_view.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

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
  
  // 変更: 単純な票数ではなく、誰が(key:被投票者) 誰から(key:投票者) いくら(value)貰ったかを記録
  // Map<被投票者Index, Map<投票者Index, 金額>>
  Map<int, Map<int, int>> voteMatrix = {};
  
  // 現在の投票者が配分中の予算データ (key:被投票者Index, value:金額)
  Map<int, int> currentAllocation = {};

  Timer? _timer;
  int _timeLeft = 30;
  int _qaTimeLeft = 30; // 質疑応答残り時間
  
  // 状態管理フラグ
  bool _isPresentationMode = true; // true: 発表, false: 質疑応答
  bool _isTimerRunning = false;    // タイマーが動いているか

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // 投票マトリクスの初期化
    for (int i = 0; i < widget.players.length; i++) {
      voteMatrix[i] = {};
    }
    
    // 最初のプレゼンターの時間をセット
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

  // --- 共通確認ダイアログ ---
  Future<void> _showConfirmDialog({required String title, String? content, required VoidCallback onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: title,
        content: content ?? "",
        onConfirm: onConfirm,
        cancelText: AppTexts.cancel, // "キャンセル" -> AppTexts.cancel
        confirmText: AppTexts.ok, // 確認ボタンのテキスト
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

  // --- タイマー処理 ---
  // タイマーの再生/停止を切り替える
  void _toggleTimer() {
    if (_isTimerRunning) {
      // 停止処理
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    } else {
      // 再生処理
      setState(() {
        _isTimerRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        
        setState(() {
          if (_isPresentationMode) {
            // 発表モード
            if (_timeLeft > 0) {
              _timeLeft--;
            } else {
              _timer?.cancel();
              _isTimerRunning = false;
              _playSound(); // 時間切れ
            }
          } else {
            // 質疑応答モード
            if (_qaTimeLeft > 0) {
              _qaTimeLeft--;
            } else {
              _timer?.cancel();
              _isTimerRunning = false;
              _playSound(); // 時間切れ
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

  // --- 進行管理 ---
  void _startPresentation() {
    _showConfirmDialog(
      title: AppTexts.presentationStartTitle, // "プレゼンを開始します"
      content: AppTexts.presentationTimeMsg(widget.settings.presentationTimeSec),
      onConfirm: () {
        setState(() {
          currentPhase = ScreenPhase.presentation;
          // 時間リセット
          _timeLeft = widget.settings.presentationTimeSec;
          _qaTimeLeft = widget.settings.qaTimeSec;
          // モード初期化（発表モード、タイマー停止）
          _isPresentationMode = true;
          _isTimerRunning = false;
        });
      }
    );
  }

  // 次のステップへ進むボタンの処理
  void _proceedToNextStep() {
    // タイマーを強制停止
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });

    if (_isPresentationMode) {
      // 発表 -> 質疑応答へ
      setState(() {
        _isPresentationMode = false;
      });
    } else {
      // 質疑応答 -> 次のプレイヤーへ
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

  // --- 投票ロジック (ここに追加) ---

  void _startVoting() {
    // 現在の投票者の配分用マップを初期化（全員0円スタート）
    currentAllocation = {};
    for (int i = 0; i < widget.players.length; i++) {
      if (i != currentVoterIndex) {
        currentAllocation[i] = 0;
      }
    }
    setState(() => currentPhase = ScreenPhase.voting);
  }

  void _submitVote() {
    // 現在の配分を確定させる
    _showConfirmDialog(
      title: AppTexts.voteConfirmTitle, // "投票の確認"
      content: AppTexts.checkBudget,
      onConfirm: () {
        // マトリクスに保存
        currentAllocation.forEach((targetIndex, amount) {
          voteMatrix[targetIndex]![currentVoterIndex] = amount;
        });

        if (currentVoterIndex < widget.players.length - 1) {
          setState(() {
            currentVoterIndex++;
            currentPhase = ScreenPhase.votingStandby;
          });
        } else {
          _calcResult();
        }
      }
    );
  }

  void _calcResult() {
    setState(() {
      currentPhase = ScreenPhase.result;
      // 結果発表の効果音再生
      try {
        _audioPlayer.play(AssetSource('audio/result.mp3'));
      } catch (e) {
        debugPrint("音声ファイルエラー: $e");
      }
    });
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
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
                // const を削除 (メソッド呼び出しのため)
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

 
  // --- プレイヤーカラーの定義 ---
  Color _getPlayerColor(int index) {
    return AppColors.playerPalette[index % AppColors.playerPalette.length];
  }

/*

 Widget _buildPresentationScreen() {
    final player = widget.players[currentPresenterIndex];

    // スタイル定義
    final activeTextStyle = AppTextStyles.valueDisplayMedium;
    final inactiveTextStyle = AppTextStyles.valueDisplayMuted;
    final activeLabelStyle = AppTextStyles.labelField;
    final inactiveLabelStyle = AppTextStyles.labelMutedSmall;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.presentationTitle(player.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _onHomePressed,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. タイマー表示エリア
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 左: 発表時間
                  Column(
                    children: [
                      Text(AppTexts.presentationTimeLabel, style: _isPresentationMode ? activeLabelStyle : inactiveLabelStyle),
                      Text(
                        AppTexts.secondsUnit(_timeLeft),
                        style: _isPresentationMode ? activeTextStyle : inactiveTextStyle,
                      ),
                      const SizedBox(height: 5),
                      // 再生/一時停止ボタン（発表モード時のみ有効）
                      if (_isPresentationMode)
                        IconButton(
                          icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          iconSize: 56,
                          color: AppColors.actionAccent,
                          onPressed: _toggleTimer,
                        )
                      else
                        const SizedBox(height: 56 + 16), // レイアウト崩れ防止のダミー
                    ],
                  ),
                  
                  // 区切り線
                  Container(width: 1, height: 100, color: AppColors.dividerStrong),

                  // 右: 質疑応答時間
                  Column(
                    children: [
                      Text(AppTexts.feedbackTitle, style: !_isPresentationMode ? activeLabelStyle : inactiveLabelStyle),
                      Text(
                        AppTexts.secondsUnit(_qaTimeLeft),
                        style: !_isPresentationMode ? activeTextStyle : inactiveTextStyle,
                      ),
                      const SizedBox(height: 5),
                      // 再生/一時停止ボタン（質疑応答モード時のみ有効）
                      if (!_isPresentationMode)
                        IconButton(
                          icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          iconSize: 56,
                          color: AppColors.actionPrimary,
                          onPressed: _toggleTimer,
                        )
                      else
                        const SizedBox(height: 56 + 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // 2. ラベル
            const Text(AppTexts.madeTitleHeader, style: AppTextStyles.headingSectionLarge),
            const SizedBox(height: 20),
            
            // 3. 研究課題タイトル (中央大きく)
            Expanded(
              child: Center(
                child: Text(
                  player.researchTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.valueDisplayLarge,
                ),
              ),
            ),
            
            // 4. 進行ボタン
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _proceedToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPresentationMode ? AppColors.actionAccent : AppColors.actionPrimary, 
                  foregroundColor: AppColors.textOnDark,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _isPresentationMode ? AppTexts.goFeedback : AppTexts.goNextPlayer,
                  style: AppTextStyles.buttonPrimaryBold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- UI: 投票画面 (予算配分) ---
  Widget _buildVotingScreen() {
    final voter = widget.players[currentVoterIndex];
    
    // 現在の使用済み予算合計
    int usedBudget = currentAllocation.values.fold(0, (sum, amount) => sum + amount);
    int remainingBudget = 100 - usedBudget;
    bool isComplete = usedBudget == 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.votingTitle(voter.name)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _onHomePressed,
        ),
      ),
      body: Column(
        children: [
          // ヘッダー：残り予算表示
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfacePanel,
            width: double.infinity,
            child: Column(
              children: [
                const Text(AppTexts.voteSelectionTitle, style: AppTextStyles.labelBold),
                const SizedBox(height: 10),
                Text(
                  AppTexts.remainBudget(remainingBudget),
                  style: AppTextStyles.valueLarge.copyWith(
                    color: remainingBudget < 0 ? AppColors.actionDanger : AppColors.textAccentStrong,
                  ),
                ),
              ],
            ),
          ),
          
          // リスト：配分スライダー
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                final p = widget.players[index];
                // 自分自身は表示しない
                if (p == voter) return const SizedBox.shrink();
                
                int currentAmount = currentAllocation[index] ?? 0;
                // スライダーの最大値 = 現在の値 + 残り予算 (これ以上増やすと100を超えるため)
                double maxVal = (currentAmount + remainingBudget).toDouble();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppTexts.researchTitle(p.researchTitle), style: AppTextStyles.labelField),
                        Text("研究者: ${p.name}", style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("$currentAmount 万円", style: AppTextStyles.amountAccent),
                            // マイナスボタン
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (currentAmount > 0) {
                                  setState(() {
                                    currentAllocation[index] = currentAmount - 1;
                                  });
                                }
                              },
                            ),
                            Expanded(
                              child: Slider(
                                value: currentAmount.toDouble(),
                                min: 0,
                                max: 100, // UI上の最大は100だが、onChangedで制御
                                divisions: 100,
                                label: "$currentAmount",
                                onChanged: (val) {
                                  int newVal = val.toInt();
                                  // 上限チェック: 増やせるのは (今の値 + 残り予算) まで
                                  if (newVal > currentAmount + remainingBudget) {
                                    newVal = currentAmount + remainingBudget;
                                  }
                                  setState(() {
                                    currentAllocation[index] = newVal;
                                  });
                                },
                              ),
                            ),
                            // プラスボタン
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (remainingBudget > 0) {
                                  setState(() {
                                    currentAllocation[index] = currentAmount + 1;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // フッター：投票ボタン
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isComplete ? AppColors.actionDanger : AppColors.actionDisabled,
                    foregroundColor: AppColors.textOnDark,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  onPressed: isComplete ? _submitVote : null,
                  child: const Text(AppTexts.decideBudget, style: AppTextStyles.buttonMediumBold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI: 結果発表画面 (積み上げ棒グラフ) ---
  Widget _buildResultScreen() {
    // 集計処理
    List<Map<String, dynamic>> results = [];
    
    for (int i = 0; i < widget.players.length; i++) {
      int total = 0;
      Map<int, int> breakdown = voteMatrix[i] ?? {};
      breakdown.forEach((_, amount) => total += amount);
      
      results.add({
        'player': widget.players[i],
        'total': total,
        'breakdown': breakdown,
      });
    }

    // 獲得金額順にソート (降順)
    results.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    // グラフの最大スケール（全員の持ち金合計）
    final int maxPossibleTotal = widget.players.length * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.resultTitle),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _onHomePressed,
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(AppTexts.resultHeader, style: AppTextStyles.headingPrimaryLarge),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final data = results[index];
                final Player p = data['player'];
                final int total = data['total'];
                final Map<int, int> breakdown = data['breakdown'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 順位と名前と金額
                        Row(
                          children: [
                            // 1位〜3位には王冠などをつける
                            if (index == 0) const Text("🥇 ", style: AppTextStyles.rankEmoji),
                            if (index == 1) const Text("🥈 ", style: AppTextStyles.rankEmoji),
                            if (index == 2) const Text("🥉 ", style: AppTextStyles.rankEmoji),
                            Text("${index + 1}位", style: AppTextStyles.headingPrimaryMedium),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: AppTextStyles.playerName),
                                  Text(p.researchTitle, style: AppTextStyles.captionMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text("$total 万円", style: AppTextStyles.amountTotal),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // 積み上げ棒グラフ
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 30,
                            color: AppColors.surfaceSubtle, // 背景色（未獲得分）
                            child: Row(
                              children: [
                                // 獲得分（積み上げ）
                                Expanded(
                                  flex: total,
                                  child: total > 0 ? Row(
                                    children: breakdown.entries.map((entry) {
                                      int voterIndex = entry.key;
                                      int amount = entry.value;
                                      if (amount == 0) return const SizedBox.shrink();
                                      
                                      return Expanded(
                                        flex: amount,
                                        child: Container(
                                          color: _getPlayerColor(voterIndex),
                                          alignment: Alignment.center,
                                          // 金額が大きい場合は数字を表示してもよい
                                          child: amount >= 10 
                                            ? Text("$amount", style: AppTextStyles.amountTinyOnDark)
                                            : null,
                                        ),
                                      );
                                    }).toList(),
                                  ) : const SizedBox.shrink(),
                                ),
                                // 未獲得分（空白）
                                Expanded(
                                  flex: maxPossibleTotal - total,
                                  child: const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 凡例（誰が何色か）
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.surfaceSubtle,
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: List.generate(widget.players.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: _getPlayerColor(index)),
                    const SizedBox(width: 4),
                    Text(widget.players[index].name, style: AppTextStyles.caption),
                  ],
                );
              }),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(AppTexts.backToTitle, style: AppTextStyles.buttonMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
*/


}