import 'card_pair.dart';

class CardBank {
  static List<CardPair> getCardPairs() {
    return [
      const CardPair(
          pairId: 'pair1',
          word: 'Cat',
          imagePath:
              'https://emojiisland.com/cdn/shop/products/CAT_emoji_icon_png_grande.png?v=1571606068'),
      const CardPair(
        pairId: 'pair2',
        word: 'Money',
        imagePath:
            'https://www.pngmart.com/files/23/Money-Emoji-Transparent-PNG.png',
      ),
      const CardPair(
        pairId: 'pair3',
        word: 'Baby',
        imagePath:
            'https://images.emojiterra.com/google/android-nougat/512px/1f476.png',
      ),
      const CardPair(
        pairId: 'pair4',
        word: 'Mango',
        imagePath:
            'https://em-content.zobj.net/source/apple/271/mango_1f96d.png',
      ),
      const CardPair(
        pairId: 'pair5',
        word: 'Star',
        imagePath:
            'https://emojiisland.com/cdn/shop/products/Star_Emoji_large.png?v=1571606063',
      )
    ];
  }

  static List<CardPair> getRandomPairs(int amount) {
    final allPairs = getCardPairs();
    allPairs.shuffle();
    return allPairs.take(amount).toList();
  }
}
