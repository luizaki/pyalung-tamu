import 'card_pair.dart';

import '../../../services/game_service.dart';

class CardBank {
  static final GameService _gameService = GameService();
  static Future<List<CardPair>> getCardPairs({
    String? difficulty,
  }) async {
    try {
      print(' CardBank Fetching pairs from mitutuglung_pairs table...');
      print('   Difficulty: $difficulty');

      final pairs = await _gameService.getMitutuglungQuestions(
        difficulty: difficulty ?? 'beginner',
      );

      print('   Fetched ${pairs.length} pairs');

      // Convert MitutuglungCardData to CardPair
      final cardPairs = pairs
          .map((pair) => CardPair(
                pairId: pair.id,
                word: pair.kapampanganWord,
                englishTrans: pair.englishTrans,
                imagePath: pair.imagePath,
              ))
          .toList();

      return cardPairs;
    } catch (e) {
      print('Error in CardBank.getCardPairs: $e');
      return [];
    }
  }

  static Future<List<CardPair>> getRandomPairs(int amount) async {
    final allPairs = await getCardPairs();
    allPairs.shuffle();
    return allPairs.take(amount).toList();
  }
}
