import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// アプリ全体で共有する効果音マネージャー（シングルトン）。
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _player = AudioPlayer();

  /// ベルを1回再生する（学会の1鈴：発表タイマー終了時）。
  Future<void> playSingleBell() async {
    try {
      await _player.play(AssetSource('audio/bell.mp3'));
    } catch (e) {
      debugPrint('AudioManager: bell play error: $e');
    }
  }

  /// ベルを2回再生する（学会の2鈴：質疑応答タイマー終了時）。
  Future<void> playDoubleBell() async {
    try {
      await _player.play(AssetSource('audio/bell.mp3'));
      await Future.delayed(const Duration(milliseconds: 400));
      await _player.play(AssetSource('audio/bell.mp3'));
    } catch (e) {
      debugPrint('AudioManager: double bell play error: $e');
    }
  }
}
