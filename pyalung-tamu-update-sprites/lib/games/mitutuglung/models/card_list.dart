import 'card_pair.dart';

class CardBank {
  static List<CardPair> getCardPairs() {
    return [
      const CardPair(
        pairId: 'pair1',
        word: 'Cat',
        imagePath:
            'https://emojiisland.com/cdn/shop/products/CAT_emoji_icon_png_grande.png?v=1571606068',
      ),
      const CardPair(
        pairId: 'pair2',
        word: 'Money',
        imagePath: 'https://cdn-icons-png.flaticon.com/256/3142/3142013.png',
      ),
      const CardPair(
        pairId: 'pair3',
        word: 'Baby',
        imagePath:
            'https://emojiisland.com/cdn/shop/products/Baby_Emoji_Icon_ios10_large.png?v=1571606090',
      ),
      const CardPair(
        pairId: 'pair4',
        word: 'Mango',
        imagePath:
            'https://static.vecteezy.com/system/resources/previews/047/130/642/non_2x/mango-fruit-cartoon-illustration-isolated-on-transparent-background-free-png.png',
      ),
      const CardPair(
        pairId: 'pair5',
        word: 'Star',
        imagePath:
            'https://emojiisland.com/cdn/shop/products/Star_Emoji_large.png?v=1571606063',
      ),
      const CardPair(
        pairId: 'pair6',
        word: 'Sun',
        imagePath:
            'https://static.vecteezy.com/system/resources/thumbnails/018/972/609/small_2x/cute-sun-illustration-design-png.png',
      )
    ];
  }

  static List<CardPair> getRandomPairs(int amount) {
    final allPairs = getCardPairs();
    allPairs.shuffle();
    return allPairs.take(amount).toList();
  }
}
