import 'package:audioplayers/audioplayers.dart'; // 音楽用
import 'package:flutter/material.dart';
import 'setup_screen.dart'; // 「新規ゲーム」を押した後の行き先
import '../constants/texts.dart'; // 追加: 定数テキストのインポート
import '../widget/fancy_button.dart'; // 追加: カスタムボタンのインポート

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // 音楽プレイヤーの作成
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playBGM();
  }

  // BGMを再生する関数
  void _playBGM() async {
    // ※ assets/audio/title_bgm.mp3 がある場合のみ再生されます
    // ループ再生の設定
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // 再生開始 (ファイルがないとエラーになるのでtry-catchしています)
    try {
      await _audioPlayer.play(AssetSource('audio/title_bgm.mp3'));
    } catch (e) {
      debugPrint("BGMファイルが見つかりません: $e");
    }
  }

  // 画面が閉じるとき（ゲーム開始時など）に音楽を止める
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stackを使うと、要素を「重ねて」表示できます（背景の上にボタン、など）
      body: Stack(
        children: [
          // --- 1. 背景画像 ---
          // 画面いっぱいに画像を広げる設定
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // ※ ここに画像ファイル名を入れる
                // 画像がないときはエラー防止のためコメントアウトし、色だけで表示しています
                image: AssetImage('assets/images/title_bg_2.png'), 
                fit: BoxFit.cover, // 画面全体を覆うように拡大縮小
              ),
              // color: Colors.blueAccent, // 画像がない時の代わりの背景色
            ),
          ),
          
          // 半透明の黒を重ねて文字を見やすくする（お好みで）
          Container(color: Colors.black.withOpacity(0.3)),

          // --- 2. ロゴとボタン ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ロゴ表示エリア
                const Spacer(), // 上の余白
                
                // --- ロゴ画像 ---
                // 画像がある場合は以下のコメントアウトを外して使ってください
                
                Image.asset(
                  'assets/images/logo_2.png',
                  width: 300, // ロゴの幅
                ), 
                
                // 画像がない時の代わりのテキスト
                // const Text(
                //   "科研費ゲーム",
                //   style: TextStyle(
                //     fontSize: 48,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 4,
                //     shadows: [
                //       Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
                //     ],
                //   ),
                // ),

                const Spacer(), // ロゴとボタンの間の余白

                // --- 新規ゲームボタン ---
                SizedBox(
                  width: 250,
                  height: 60,
                  child: FancyButton(
                    text: AppTexts.newGameButton,
                    color: Colors.orange,
                    icon: Icons.play_arrow,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SetupScreen()),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 100), // 下の余白
              ],
            ),
          ),
        ],
      ),
    );
  }
}