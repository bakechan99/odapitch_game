import 'card_data.dart';

class PlacedCard {
  final CardData card;
  // 0: 上段(Top), 1: 中段(Middle), 2: 下段(Bottom)
  int selectedSection;

  PlacedCard({required this.card, this.selectedSection = 0});

  // 現在選ばれているテキストを取得する便利機能
  String get selectedText {
    switch (selectedSection) {
      case 0: return card.top;
      case 1: return card.middle;
      case 2: return card.bottom;
      default: return "";
    }
  }
}