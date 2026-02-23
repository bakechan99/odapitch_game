class CardPreset {
  final String id;
  final String name;
  final String path;

  CardPreset({
    required this.id,
    required this.name,
    required this.path,
  });

  factory CardPreset.fromJson(Map<String, dynamic> json) {
    return CardPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
    );
  }
}
