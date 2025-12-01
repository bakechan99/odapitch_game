import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../constants/texts.dart';

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
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: content != null ? Text(content) : null,
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppTexts.cancel)), // "キャンセル" -> AppTexts.cancel
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // --- タイマー処理 ---
  void _startTimer() {
    setState(() {
      _timeLeft = widget.settings.presentationTimeSec; // 設定画面の時間を使う
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _playSound();
        }
      });
    });
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
        setState(() => currentPhase = ScreenPhase.presentation);
        _startTimer();
      }
    );
  }

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
      title: AppTexts.voteConfirmTitle,
      content: "この配分で投票しますか？",
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
      _audioPlayer.play(AssetSource('audio/result.mp3'));
    });
    // 自動遷移は削除し、ボタンで戻るようにする（結果をじっくり見るため）
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
        return _buildPresentationScreen();
      case ScreenPhase.votingStandby:
        return _buildStandbyScreen(
          player: widget.players[currentVoterIndex],
          message: AppTexts.nextVoter,
          onReady: _startVoting,
        );
      case ScreenPhase.voting:
        return _buildVotingScreen();
      case ScreenPhase.result:
        return _buildResultScreen();
    }
  }

  Widget _buildStandbyScreen({required Player player, required String message, required VoidCallback onReady}) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
             decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blueGrey, Colors.black87], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const を削除 (メソッド呼び出しのため)
                Text(AppTexts.nextPlayerStandby(player.name), style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onReady,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: const Text("START", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentationScreen() {
    final player = widget.players[currentPresenterIndex];
    final isTimeUp = _timeLeft == 0;

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.presentationTitle(player.name))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(AppTexts.timeLeft(_timeLeft), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: isTimeUp ? Colors.red : Colors.black)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
              // 修正箇所 (Line 217付近): メソッド呼び出し
              child: Text(AppTexts.researchTitle(player.researchTitle), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const Spacer(),
            if (isTimeUp)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Text(AppTexts.nextPlayerButton), // "次のプレイヤーへ"
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- プレイヤーカラーの定義 ---
  Color _getPlayerColor(int index) {
    const colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.brown
    ];
    return colors[index % colors.length];
  }

  // --- UI: 投票画面 (予算配分) ---
  Widget _buildVotingScreen() {
    final voter = widget.players[currentVoterIndex];
    
    // 現在の使用済み予算合計
    int usedBudget = currentAllocation.values.fold(0, (sum, amount) => sum + amount);
    int remainingBudget = 100 - usedBudget;
    bool isComplete = usedBudget == 100;

    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.votingTitle(voter.name))),
      body: Column(
        children: [
          // ヘッダー：残り予算表示
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey[50],
            width: double.infinity,
            child: Column(
              children: [
                const Text("最も予算を与えたい研究に配分してください", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  "残り予算: $remainingBudget 万円 / 100 万円",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: remainingBudget < 0 ? Colors.red : Colors.blue[800]
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
                        Text(AppTexts.researchTitle(p.researchTitle), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("研究者: ${p.name}", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text("$currentAmount 万円", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                    backgroundColor: isComplete ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  onPressed: isComplete ? _submitVote : null,
                  child: const Text("投票を確定する", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.resultTitle)), // "🎉 結果発表 🎉"
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(AppTexts.resultHeader, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            if (index == 0) const Text("🥇 ", style: TextStyle(fontSize: 24)),
                            if (index == 1) const Text("🥈 ", style: TextStyle(fontSize: 24)),
                            if (index == 2) const Text("🥉 ", style: TextStyle(fontSize: 24)),
                            Text("${index + 1}位", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text(p.researchTitle, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text("$total 万円", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // 積み上げ棒グラフ
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 30,
                            child: Row(
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
                                      ? Text("$amount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                                      : null,
                                  ),
                                );
                              }).toList(),
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
            color: Colors.grey[200],
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: List.generate(widget.players.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: _getPlayerColor(index)),
                    const SizedBox(width: 4),
                    Text(widget.players[index].name, style: const TextStyle(fontSize: 12)),
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
                  child: const Text(AppTexts.backToTitle, style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}