class CardModel {
  final int id;
  final String content; // Could be an image path or any identifier
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.id,
    required this.content,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}