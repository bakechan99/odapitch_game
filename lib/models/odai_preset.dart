class OdaiPreset {
  final String id;
  final String name;
  final String odai;

  const OdaiPreset({
    required this.id,
    required this.name,
    required this.odai,
  });

  factory OdaiPreset.fromJson(Map<String, dynamic> json) {
    return OdaiPreset(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      odai: (json['odai'] ?? '').toString(),
    );
  }
}
