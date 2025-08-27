import '../../shared/models/base_game_state.dart';
import 'word.dart';
import 'boat.dart';

import '../../../services/game_service.dart';

class BangkaGameState extends BaseGameState {
  List<WordData> wordBank;
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
    List<WordData>? wordBank,
    this.currentWord,
    List<TypedWord>? completedWords,
    Boat? boat,
    this.totalCharacters = 0,
    this.correctCharacters = 0,
    this.totalWords = 0,
    this.currentWPM = 0.0,
    this.gameStartTime,
  })  : wordBank =
            wordBank ?? [WordData(baseForm: 'none', englishTrans: 'none')],
        completedWords = completedWords ?? [],
        boat = boat ?? Boat();

  @override
  double get accuracy =>
      totalCharacters > 0 ? correctCharacters / totalCharacters : 1.0;

  double get progress => boat.position;

  int get wordsCompleted => completedWords.length;
}
