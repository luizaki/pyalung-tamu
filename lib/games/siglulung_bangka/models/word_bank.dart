import '../../../services/game_service.dart';

class WordBank {
  static final GameService _gameService = GameService();

  static Future<List<String>> getWords({
    String? difficulty,
  }) async {
    try {
      print('   Wordbank: Fetching words from database...');
      print('   Difficulty: $difficulty');

      final words = await _gameService.getWordsByDifficulty(
        difficulty: difficulty ?? 'beginner',
      );

      print('   Fetched ${words.length} words');

      return words;
    } catch (e) {
      print('Error fetching words: $e');
      return [''];
    }
  }

  static Future<List<String>> getRandomWords(
      String difficulty, int count) async {
    final words = await getWords(difficulty: difficulty);
    words.shuffle();
    return words.take(count).toList();
  }

  static Future<String> getRandomWord(String difficulty) async {
    final words = await getWords(difficulty: difficulty);
    words.shuffle();
    return words.first;
  }
}
