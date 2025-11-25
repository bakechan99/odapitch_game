import 'card_data.dart'; // さっき作ったファイルを使うよ、という宣言

class Player {
  String name;
  List<CardData> hand = [];
  List<CardData> selectedCards = []; // 選んで並べたカード
  
  Player({required this.name});
}