import 'dart:async';
import 'package:flutter/material.dart';

import '../../shared/controllers/base_game_controller.dart';
import '../../shared/models/base_game_state.dart';

import '../models/game_state.dart';
import '../models/card.dart';
import '../models/card_list.dart';
import '../models/card_pair.dart';

class MitutuglungGameController
    extends BaseGameController<MitutuglungGameState> {
  // Game data
  List<CardPair> _cardPairs = [];
  List<CardPair> get cardPairs => _cardPairs;

  // Game configs
  static const int PAIRS_COUNT = 6;
  static const int PREVIEW_DURATION = 5;
  static const int MISMATCH_DELAY = 1;

  // Timers
  Timer? _previewTimer;
  Timer? _mismatchTimer;

  MitutuglungGameController() : super(MitutuglungGameState());

  @override
  int get gameDuration => 90;

  // ================== IMPLEMENTED INITS ==================

  @override
  void initializeGameData() {
    _cardPairs = CardBank.getRandomPairs(PAIRS_COUNT);
  }

  @override
  void initializeGameSpecifics(Size screenSize) {
    gameState.revealedCards.clear();
    gameState.pairsFound = 0;
    gameState.isProcessingMove = false;
    gameState.isShowingCards = false;
    _prepareCardPairs();
  }

  @override
  void resetGameState() {
    gameState =
        MitutuglungGameState(timeLeft: gameDuration, totalPairs: PAIRS_COUNT);
  }

  void _prepareCardPairs() {
    final cards = <MitutuglungCard>[];

    for (final pair in _cardPairs) {
      cards.addAll(pair.toCards());
    }

    cards.shuffle();

    gameState.cards = cards;
    gameState.totalPairs = _cardPairs.length;
  }

  // ============== IMPLEMENTED LIFECYCLES ==============

  @override
  void onGameStarted() {
    _startPreviewPhase();
  }

  // ================ IMPLEMENTED TIMERS ================

  @override
  void pauseGameSpecificTimers() {
    _previewTimer?.cancel();
    _mismatchTimer?.cancel();
  }

  @override
  void resumeGameSpecificTimers() {}

  @override
  void stopGameSpecificTimers() {
    _previewTimer?.cancel();
    _mismatchTimer?.cancel();
  }

  // ================ PREVIEW PHASES ================

  void _startPreviewPhase() {
    gameState.isShowingCards = true;

    pauseGameTimer();

    for (final card in gameState.cards) {
      card.reveal();
    }

    notifyListeners();

    _previewTimer = Timer(const Duration(seconds: PREVIEW_DURATION), () {
      _endPreviewPhase();
    });
  }

  void _endPreviewPhase() {
    gameState.isShowingCards = false;

    for (final card in gameState.cards) {
      card.hide();
    }

    resumeGameTimer();

    notifyListeners();
  }

  // ================== CARD MANAGEMENT ==================

  void _checkForMatch() {
    final card1 = gameState.revealedCards[0];
    final card2 = gameState.revealedCards[1];

    if (_areCardsMatching(card1, card2)) {
      _handleMatch(card1, card2);
    } else {
      _handleMismatch(card1, card2);
    }
  }

  bool _areCardsMatching(MitutuglungCard card1, MitutuglungCard card2) {
    return card1.pairId == card2.pairId && card1.type != card2.type;
  }

  void _handleMatch(MitutuglungCard card1, MitutuglungCard card2) {
    card1.match();
    card2.match();

    gameState.pairsFound++;
    gameState.revealedCards.clear();
    gameState.isProcessingMove = false;

    onCorrectAnswer(points: 20);

    notifyListeners();

    if (gameState.isComplete) {
      Timer(const Duration(milliseconds: 500), () {
        endGame();
      });
    }
  }

  void _handleMismatch(MitutuglungCard card1, MitutuglungCard card2) {
    onIncorrectAnswer();

    _mismatchTimer = Timer(const Duration(seconds: MISMATCH_DELAY), () {
      card1.hide();
      card2.hide();
      gameState.revealedCards.clear();
      gameState.isProcessingMove = false;
      notifyListeners();
    });
  }

  // ================== USER INTERACTIONS ==================

  bool canTapCard(MitutuglungCard card) {
    return !gameState.isShowingCards &&
        !gameState.isProcessingMove &&
        gameState.status == GameStatus.playing &&
        card.isHidden &&
        gameState.revealedCards.length < 2;
  }

  void onCardTapped(MitutuglungCard card) {
    if (!canTapCard(card)) return;

    card.reveal();
    gameState.revealedCards.add(card);
    notifyListeners();

    if (gameState.revealedCards.length == 2) {
      gameState.isProcessingMove = true;
      _checkForMatch();
    }
  }

  // ================== HELPER METHODS ==================

  List<List<MitutuglungCard>> getCardsGrid() {
    const cardsPerRow = 4;
    final grid = <List<MitutuglungCard>>[];

    for (int i = 0; i < gameState.cards.length; i += cardsPerRow) {
      final rowEnd = (i + cardsPerRow < gameState.cards.length)
          ? i + cardsPerRow
          : gameState.cards.length;
      final row = gameState.cards.sublist(i, rowEnd);
      grid.add(row);
    }

    return grid;
  }
}
