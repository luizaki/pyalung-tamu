import '../../shared/models/base_game_state.dart';
import 'word.dart';
import 'boat.dart';

class BangkaGameState extends BaseGameState {
  List<String> wordBank;
  TypedWord? currentWord;
  List<TypedWord> completedWords;
  Boat boat;

  int totalCharacters;
  int correctCharacters;
  int totalWords;
  double currentWPM;
  DateTime? gameStartTime;

  BangkaGameState({
    super.score,
    super.timeLeft,
    super.correctAnswers,
    super.totalAnswers,
    super.status,
    super.isCountingDown,
    super.countdownValue,
    List<String>? wordBank,
    this.currentWord,
    List<TypedWord>? completedWords,
    Boat? boat,
    this.totalCharacters = 0,
    this.correctCharacters = 0,
    this.totalWords = 0,
    this.currentWPM = 0.0,
    this.gameStartTime,
  })  : wordBank = wordBank ?? [],
        completedWords = completedWords ?? [],
        boat = boat ?? Boat();

  @override
  double get accuracy =>
      totalCharacters > 0 ? correctCharacters / totalCharacters : 1.0;

  double get progress => boat.position;

  int get wordsCompleted => completedWords.length;
}
