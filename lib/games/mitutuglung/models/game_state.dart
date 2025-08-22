import '../../shared/models/base_game_state.dart';
import './card.dart';

class MitutuglungGameState extends BaseGameState {
  List<MitutuglungCard> cards;
  List<MitutuglungCard> revealedCards;

  int pairsFound;
  int totalPairs;

  bool isProcessingMove;
  bool isShowingCards;

  MitutuglungGameState({
    super.score,
    super.timeLeft,
    super.correctAnswers,
    super.totalAnswers,
    super.status,
    super.isCountingDown,
    super.countdownValue,
    this.pairsFound = 0,
    this.totalPairs = 0,
    this.isProcessingMove = false,
    this.isShowingCards = false,
    List<MitutuglungCard>? cards,
    List<MitutuglungCard>? revealedCards,
  })  : cards = cards ?? [],
        revealedCards = revealedCards ?? [];

  double get progress => totalPairs > 0 ? pairsFound / totalPairs : 0.0;
  bool get isComplete => pairsFound == totalPairs;
}
