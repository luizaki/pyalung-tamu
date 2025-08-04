import './frog.dart';

enum GameStatus { menu, playing, paused, gameOver }

class TugakGameState {
  int score;
  int timeLeft;
  int frogsAnswered;
  int correctAnswers;
  GameStatus status;
  List<Frog> frogs;

  TugakGameState({
    this.score = 0,
    this.timeLeft = 60,
    this.frogsAnswered = 0,
    this.correctAnswers = 0,
    this.status = GameStatus.menu,
    List<Frog>? frogs,
  }) : frogs = frogs ?? [];

  double get accuracy =>
      frogsAnswered > 0 ? correctAnswers / frogsAnswered : 0.0;
}
