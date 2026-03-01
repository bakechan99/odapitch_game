class CardPreset {
  final String id;
  final String name;
  final String path;
  final String odai; // 追加: お題のフィールド

  CardPreset({
    required this.id,
    required this.name,
    required this.path,
    required this.odai,
  });

  factory CardPreset.fromJson(Map<String, dynamic> json) {
    return CardPreset(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      odai: (json['odai'] ?? '').toString(),
    );
  }
}
