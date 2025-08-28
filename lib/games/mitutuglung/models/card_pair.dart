import './card.dart';

class CardPair {
  final String pairId;
  final String word;
  final String englishTrans;
  final String imagePath;

  const CardPair({
    required this.pairId,
    required this.word,
    this.englishTrans = '',
    required this.imagePath,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardPair && other.pairId == pairId;
  }

  @override
  int get hashCode => pairId.hashCode;

  List<MitutuglungCard> toCards() {
    return [
      MitutuglungCard(
        id: '${pairId}_word',
        content: word,
        englishTrans: englishTrans,
        type: CardType.word,
        pairId: pairId,
      ),
      MitutuglungCard(
        id: '${pairId}_image',
        content: imagePath,
        englishTrans: englishTrans,
        type: CardType.image,
        pairId: pairId,
      ),
    ];
  }
}
