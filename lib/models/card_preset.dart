class CardPreset {
  final String id;
  final String name;
  final String path;
  final String odaiPath;

  CardPreset({
    required this.id,
    required this.name,
    required this.path,
    required this.odaiPath,
  });

  factory CardPreset.fromJson(Map<String, dynamic> json) {
    return CardPreset(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      odaiPath: (json['odaiPath'] ?? 'assets/odai_presets/odai_cards.json').toString(),
    );
  }
}
