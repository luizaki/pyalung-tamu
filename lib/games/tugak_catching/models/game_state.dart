import '../../shared/models/base_game_state.dart';
import './frog.dart';

class TugakGameState extends BaseGameState {
  int frogsAnswered;
  List<Frog> frogs;

  TugakGameState({
    super.score,
    super.timeLeft,
    super.correctAnswers,
    super.totalAnswers,
    super.isCountingDown,
    super.countdownValue,
    this.frogsAnswered = 0,
    List<Frog>? frogs,
  }) : frogs = frogs ?? [];

  double get frogAccuracy =>
      frogsAnswered > 0 ? correctAnswers / frogsAnswered : 0.0;
}
