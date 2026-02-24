import 'card_data.dart';
import 'placed_card.dart'; // 追加

class Player {
  String name;
  List<CardData> hand = [];
  // ここを CardData から PlacedCard に変更
  List<PlacedCard> selectedCards = []; 

  //AI関連保存領域
  String? aiFeedback;
  double aiScore = 0.0;
  
  Player({required this.name,this.aiFeedback, this.aiScore = 0.0});
  
  // 研究タイトルを生成するゲッター
  String get researchTitle {
    if (selectedCards.isEmpty) return "（未設定）";
    return selectedCards.map((pc) => pc.selectedText).join("");
  }
}