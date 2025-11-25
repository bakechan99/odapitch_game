class CardData {
  final int id;
  final String top;    // 研究キーワード
  final String middle; // 接続詞・修飾語
  final String bottom; // 締めの言葉

  CardData({
    required this.id,
    required this.top,
    required this.middle,
    required this.bottom
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      id: json['id'],
      top: json['top'],
      middle: json['middle'] ?? "",
      bottom: json['bottom'],
    );
  }
}