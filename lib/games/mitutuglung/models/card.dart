enum CardType { word, image }

enum CardState { hidden, revealed, matched }

class MitutuglungCard {
  final String id;
  final String content;
  final String englishTrans;
  final CardType type;
  final String pairId;

  CardState state;

  MitutuglungCard({
    required this.id,
    required this.content,
    this.englishTrans = '',
    required this.type,
    required this.pairId,
    this.state = CardState.hidden,
  });

  bool get isWord => type == CardType.word;
  bool get isImage => type == CardType.image;
  bool get isHidden => state == CardState.hidden;
  bool get isRevealed => state == CardState.revealed;
  bool get isMatched => state == CardState.matched;

  void reveal() => state = CardState.revealed;
  void hide() => state = CardState.hidden;
  void match() => state = CardState.matched;
}
