import 'card_data.dart';
import 'placed_card.dart'; // 追加

class Player {
  String name;
  List<CardData> hand = [];
  // ここを CardData から PlacedCard に変更
  List<PlacedCard> selectedCards = []; 
  
  Player({required this.name});
}