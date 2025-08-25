import './card.dart';

class CardPair {
  final String pairId;
  final String word;
  final String imagePath;

  const CardPair({
    required this.pairId,
    required this.word,
    required this.imagePath,
  });

  List<MitutuglungCard> toCards() {
    return [
      MitutuglungCard(
        id: '${pairId}_word',
        content: word,
        type: CardType.word,
        pairId: pairId,
      ),
      MitutuglungCard(
        id: '${pairId}_image',
        content: imagePath,
        type: CardType.image,
        pairId: pairId,
      ),
    ];
  }
}
