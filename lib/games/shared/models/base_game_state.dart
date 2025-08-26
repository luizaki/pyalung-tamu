enum GameStatus { menu, playing, paused, completed, ended }

class BaseGameState {
  int score;
  int timeLeft;
  int totalAnswers;
  int correctAnswers;
  GameStatus status;

  bool isCountingDown;
  int countdownValue;

  BaseGameState({
    this.score = 0,
    this.timeLeft = 60,
    this.totalAnswers = 0,
    this.correctAnswers = 0,
    this.status = GameStatus.menu,
    this.isCountingDown = false,
    this.countdownValue = 3,
  });

  double get accuracy => totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
}
