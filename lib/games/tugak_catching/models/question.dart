// NOTE: THIS IS FOR DUMMY / TEST PURPOSES ONLY.
// TODO: Remove/revise this file when the database is actually implemented.

class Question {
  final String question;
  final List<String> choices;
  final String correctAnswer;

  late List<String> shuffledChoices;
  late int correctIndex;

  Question({
    required this.question,
    required this.choices,
    required this.correctAnswer,
  }) {
    _initialShuffle();
  }

  // an internal shuffle method to immediately initialize shuffling
  void _initialShuffle() {
    shuffledChoices = List.from(choices)..shuffle();
    correctIndex = shuffledChoices.indexOf(correctAnswer);
  }

  void shuffle() {
    _initialShuffle();
  }
}

class QuestionBank {
  static List<Question> getQuestions() {
    return [
      Question(
        question: 'Maria _____ a lesson plan for her class yesterday.',
        choices: ['prepares', 'prepared', 'will prepare'],
        correctAnswer: 'prepared',
      ),
      Question(
        question: 'The students _____ their homework every day.',
        choices: ['do', 'does', 'did'],
        correctAnswer: 'do',
      ),
      Question(
        question: 'He _____ to the library last week.',
        choices: ['goes', 'went', 'going'],
        correctAnswer: 'went',
      ),
      Question(
        question: 'Carlos _____ his friends at the park tomorrow.',
        choices: ['meets', 'met', 'will meet'],
        correctAnswer: 'will meet',
      ),
      Question(
        question: 'They _____ a movie last night.',
        choices: ['watch', 'watches', 'watched'],
        correctAnswer: 'watched',
      )
    ];
  }
}
