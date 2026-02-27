class GameSettings {
  final int presentationTimeSec; // プレゼン時間（秒）
  final int qaTimeSec; // 質疑応答時間（秒）
  final int playerCount;

  static const int defaultPresentationTimeSec = 30;
  static const int defaultQaTimeSec = 30;
  static const int defaultPlayerCount = 3;

  static const GameSettings defaults = GameSettings(
    presentationTimeSec: defaultPresentationTimeSec,
    qaTimeSec: defaultQaTimeSec,
    playerCount: defaultPlayerCount,
  );
  
  const GameSettings({
    required this.presentationTimeSec,
    required this.qaTimeSec,
    this.playerCount = defaultPlayerCount,
  });

  GameSettings copyWith({
    int? presentationTimeSec,
    int? qaTimeSec,
    int? playerCount,
  }) {
    return GameSettings(
      presentationTimeSec: presentationTimeSec ?? this.presentationTimeSec,
      qaTimeSec: qaTimeSec ?? this.qaTimeSec,
      playerCount: playerCount ?? this.playerCount,
    );
  }

  Map<String, String> toSettingsMap() {
    return {
      'presentation_time_sec': presentationTimeSec.toString(),
      'qa_time_sec': qaTimeSec.toString(),
      'player_count': playerCount.toString(),
    };
  }

  factory GameSettings.fromSettingsMap(Map<String, String?> map) {
    return GameSettings(
      presentationTimeSec:
          int.tryParse(map['presentation_time_sec'] ?? '') ?? defaultPresentationTimeSec,
      qaTimeSec: int.tryParse(map['qa_time_sec'] ?? '') ?? defaultQaTimeSec,
      playerCount: int.tryParse(map['player_count'] ?? '') ?? defaultPlayerCount,
    );
  }
}