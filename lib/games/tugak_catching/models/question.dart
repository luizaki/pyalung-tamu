import '../../../services/game_service.dart';

class Question {
  final String question;
  final String englishTrans;
  final List<String> choices;
  final List<String> engChoices;
  final String correctAnswer;

  late List<String> shuffledChoices;
  late List<String> shuffledEngChoices;
  late int correctIndex;

  Question({
    required this.question,
    this.englishTrans = '',
    required this.correctAnswer,
    required this.choices,
    required this.engChoices,
  }) {
    _initialShuffle();
  }

  // an internal shuffle method to immediately initialize shuffling
  void _initialShuffle() {
    final paired = List.generate(
      choices.length,
      (i) => MapEntry(choices[i], engChoices[i]),
    );

    paired.shuffle();

    shuffledChoices = paired.map((e) => e.key).toList();
    shuffledEngChoices = paired.map((e) => e.value).toList();

    correctIndex = shuffledChoices.indexOf(correctAnswer);
  }

  void shuffle() {
    _initialShuffle();
  }
}

class QuestionBank {
  static final GameService _gameService = GameService();

  static Future<List<Question>> getQuestions({
    String? difficulty,
  }) async {
    try {
      final tugakData = await _gameService.getTugakQuestions(
          difficulty: difficulty ?? 'beginner');

      print('   Fetched ${tugakData.length} questions');

      // Convert TugakQuestionData to Question
      final questions = tugakData
          .map((data) => Question(
                question: data.textWithBlank,
                englishTrans: data.sentenceEng,
                correctAnswer: data.correctTense,
                choices: data.getOptions(),
                engChoices: data.getEngOptions(),
              ))
          .toList();

      return questions;
    } catch (e) {
      print(' Error fetching questions: $e');
      return [
        Question(
            question: '', correctAnswer: '', choices: [''], engChoices: [''])
      ];
    }
  }
}
