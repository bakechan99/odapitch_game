import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/placed_card.dart';
import '../models/game_settings.dart'; // 設定モデル
import '../utils/app_texts.dart'; // AppTextsをインポート

enum ScreenPhase { presentationStandby, presentation, votingStandby, voting, result }

class ResultScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings; // 設定を受け取る
  const ResultScreen({super.key, required this.players, required this.settings});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ScreenPhase currentPhase = ScreenPhase.presentationStandby;
  int currentPresenterIndex = 0;
  int currentVoterIndex = 0;
  List<int> voteCounts = [];
  Timer? _timer;
  int _timeLeft = 30;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    voteCounts = List.filled(widget.players.length, 0);
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
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
      title: "プレゼンを開始します",
      content: "時間は${widget.settings.presentationTimeSec}秒です。",
      onConfirm: () {
        setState(() => currentPhase = ScreenPhase.presentation);
        _startTimer();
      }
    );
  }

  void _finishPresentation() {
    _showConfirmDialog(
      title: "発表を終了しますか？",
      onConfirm: () {
        _timer?.cancel();
        _audioPlayer.stop();
        if (currentPresenterIndex < widget.players.length - 1) {
          setState(() {
            currentPresenterIndex++;
            currentPhase = ScreenPhase.presentationStandby;
          });
        } else {
          setState(() => currentPhase = ScreenPhase.votingStandby);
        }
      }
    );
  }

  void _startVoting() {
    _showConfirmDialog(
      title: "投票を開始します",
      onConfirm: () => setState(() => currentPhase = ScreenPhase.voting)
    );
  }

  void _submitVote(int targetIndex) {
    String targetName = widget.players[targetIndex].name;
    _showConfirmDialog(
      title: "投票確認",
      content: "$targetName さんに投票しますか？",
      onConfirm: () {
        voteCounts[targetIndex]++;
        if (currentVoterIndex < widget.players.length - 1) {
          setState(() {
            currentVoterIndex++;
            currentPhase = ScreenPhase.votingStandby;
          });
        } else {
          setState(() => currentPhase = ScreenPhase.result);
        }
      }
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    switch (currentPhase) {
      case ScreenPhase.presentationStandby:
        return _buildStandbyScreen(
          player: widget.players[currentPresenterIndex],
          message: AppTexts.nextPresenter, // "次は発表の番です" -> AppTexts.nextPresenter
          onReady: _startPresentation, // ダイアログありの関数を呼ぶ
        );
      case ScreenPhase.presentation:
        return _buildPresentationScreen();
      case ScreenPhase.votingStandby:
        return _buildStandbyScreen(
          player: widget.players[currentVoterIndex],
          message: AppTexts.nextVoter, // "次は投票の番です" -> AppTexts.nextVoter
          onReady: _startVoting, // ダイアログありの関数を呼ぶ
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
                Text("次は ${player.name} さん", style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 40),
                const Icon(Icons.phone_android, size: 80, color: Colors.white),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onReady,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("準備OK", style: TextStyle(fontSize: 20)),
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
      appBar: AppBar(title: Text("${player.name} の発表")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("残り $_timeLeft 秒", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: isTimeUp ? Colors.red : Colors.black)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent, width: 4),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("【今回の研究課題】", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: player.selectedCards.map((p) => Text(p.selectedText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))).toList(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _finishPresentation,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                child: const Text("発表終了（次の人へ）", style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingScreen() {
    final voter = widget.players[currentVoterIndex];
    return Scaffold(
      appBar: AppBar(title: Text("${voter.name} の投票")),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(16.0), child: Text("最も予算を与えたい研究を選んでください", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                final candidate = widget.players[index];
                if (index == currentVoterIndex) return const SizedBox.shrink();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(candidate.selectedCards.map((c) => c.selectedText).join(""), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: ElevatedButton(onPressed: () => _submitVote(index), child: const Text("投票")),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int maxVotes = 0;
    for (var count in voteCounts) { if (count > maxVotes) maxVotes = count; }
    List<Player> winners = [];
    for (int i = 0; i < widget.players.length; i++) { if (voteCounts[i] == maxVotes) winners.add(widget.players[i]); }

    return Scaffold(
      appBar: AppBar(title: const Text("🎉 結果発表 🎉")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("採択された研究課題は...", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ...winners.map((w) => Text("👑 ${w.name}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange))),
            const SizedBox(height: 20),
            Text("獲得票数: $maxVotes 票", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("タイトルへ戻る"),
            )
          ],
        ),
      ),
    );
  }
}