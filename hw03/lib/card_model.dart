/*
* Defines properties for each card
*/
class CardModel {
  final int id;
  final String content; 
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.id,
    required this.content,
    // If card face-up
    this.isFaceUp = false,
    // If card has been matched in a pair
    this.isMatched = false,
  });
}