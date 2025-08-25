import 'dart:async';
import 'package:flutter/material.dart';

import '../../shared/controllers/base_game_controller.dart';
import '../../shared/models/base_game_state.dart';

import '../models/game_state.dart';
import '../models/boat.dart';
import '../models/word.dart';
import '../models/word_bank.dart';

class BangkaGameController extends BaseGameController<BangkaGameState> {
  // Game data
  List<String> _upcomingWords = [];

  // Game configs
  static const boatUpdateInterval = 8;
  static const wpmUpdateInterval = 300;

  // Timers
  Timer? _boatAnimationTimer;
  Timer? _wpmUpdateTimer;

  BangkaGameController() : super(BangkaGameState());

  @override
  int get gameDuration => 30;

  // ================== IMPLEMENTED INITS ==================

  @override
  void initializeGameData() {
    gameState.wordBank = WordBank.getWords();
  }

  @override
  void initializeGameSpecifics(Size screenSize) {
    _resetGameSpecifics();
    _generateFirstWord();
  }

  @override
  void resetGameState() {
    gameState = BangkaGameState(
      timeLeft: gameDuration,
      wordBank: gameState.wordBank,
    );
  }

  // ============== IMPLEMENTED LIFECYCLES ==============

  @override
  void onGameStarted() {
    gameState.gameStartTime = DateTime.now();

    _startBoatAnimation();
    _startWpmTracking();
  }

  // ================ IMPLEMENTED TIMERS ================

  @override
  void pauseGameSpecificTimers() {
    _boatAnimationTimer?.cancel();
    _wpmUpdateTimer?.cancel();
  }

  @override
  void resumeGameSpecificTimers() {
    if (gameState.status == GameStatus.playing) {
      _startBoatAnimation();
      _startWpmTracking();
    }
  }

  @override
  void stopGameSpecificTimers() {
    _boatAnimationTimer?.cancel();
    _wpmUpdateTimer?.cancel();
  }

  // ================ WORDS MANAGEMENT ================

  void _resetGameSpecifics() {
    gameState.currentWord = null;
    gameState.completedWords.clear();
    gameState.boat = Boat();
    gameState.totalCharacters = 0;
    gameState.correctCharacters = 0;
    gameState.currentWPM = 0.0;
    gameState.gameStartTime = null;

    _generateWordQueue();
  }

  void _generateWordQueue() {
    _upcomingWords = WordBank.getRandomWords(10);
  }

  void _generateFirstWord() {
    if (_upcomingWords.isNotEmpty && gameState.status != GameStatus.gameOver) {
      final word = _upcomingWords.removeAt(0);
      gameState.currentWord = TypedWord(word: word);

      // Refill queue if running low
      if (_upcomingWords.length < 5) {
        _upcomingWords.addAll(WordBank.getRandomWords(5));
      }

      notifyListeners();
    }
  }

  void _generateNextWord() {
    if (_upcomingWords.isNotEmpty && gameState.status != GameStatus.gameOver) {
      final word = _upcomingWords.removeAt(0);
      gameState.currentWord = TypedWord(word: word);

      // Keep queue filled
      if (_upcomingWords.length < 5) {
        _upcomingWords.addAll(WordBank.getRandomWords(5));
      }

      notifyListeners();
    }
  }

  // ================ BOAT AND WPM ================

  void _startBoatAnimation() {
    _boatAnimationTimer = Timer.periodic(
        const Duration(milliseconds: boatUpdateInterval), (timer) {
      if (gameState.status == GameStatus.playing) {
        gameState.boat.move(boatUpdateInterval.toDouble());

        gameState.boat.updateSpeed(gameState.currentWPM);

        notifyListeners();
      }
    });
  }

  void _startWpmTracking() {
    _wpmUpdateTimer = Timer.periodic(
        const Duration(milliseconds: wpmUpdateInterval), (timer) {
      if (gameState.status == GameStatus.playing) {
        _calculateWPM();
        notifyListeners();
      }
    });
  }

  void _calculateWPM() {
    if (gameState.gameStartTime == null) return;

    final elapsedTime = DateTime.now().difference(gameState.gameStartTime!);
    final minutes = elapsedTime.inMilliseconds / 60000.0;

    if (minutes > 0) {
      gameState.currentWPM = gameState.wordsCompleted / minutes;
    }
  }

  // ================ USER INTERACTIONS ================

  void onKeyPressed(String key) {
    if (!isGameActive || gameState.currentWord == null) return;

    final currentWord = gameState.currentWord!;

    if (key == 'Backspace') {
      _handleBackspace(currentWord);
    } else if (key == ' ' || key == 'Enter') {
      _handleWordSubmission(currentWord);
    } else if (key.length == 1 &&
        key.codeUnitAt(0) >= 32 &&
        key.codeUnitAt(0) <= 126) {
      _handleCharacterInput(currentWord, key);
    }
  }

  void _handleCharacterInput(TypedWord currentWord, String character) {
    currentWord.addCharacter(character);
    gameState.totalCharacters++;

    if (currentWord.isCorrect) {
      gameState.correctCharacters++;
    } else {
      gameState.boat.hit();
    }

    if (currentWord.isCompleted) {
      _completeCurrentWord();
    }

    notifyListeners();
  }

  void _handleBackspace(TypedWord currentWord) {
    if (currentWord.typedText.isNotEmpty) {
      currentWord.removeCharacter();
      notifyListeners();
    }
  }

  void _handleWordSubmission(TypedWord currentWord) {
    if (currentWord.typedText.isNotEmpty) {
      if (currentWord.isCorrect &&
          currentWord.typedText.length == currentWord.word.length) {
        _completeCurrentWord();
      } else {
        gameState.boat.hit();
        notifyListeners();
      }
    }
  }

  void _completeCurrentWord() {
    final currentWord = gameState.currentWord;

    gameState.completedWords.add(currentWord!);
    gameState.totalWords++;

    if (currentWord.typedText != currentWord.word) {
      return;
    }

    final points = currentWord.word.length * 2;
    onCorrectAnswer(points: points);

    _generateNextWord();
  }

  // ================== GETTERS ==================

  String get currentWordDisplay {
    if (gameState.currentWord == null) return '';

    final word = gameState.currentWord!;
    final typed = word.typedText;
    final remaining = word.remainingText;

    return '$typed|$remaining'; // | represents cursor
  }

  String get wpmDisplay => '${gameState.currentWPM.toStringAsFixed(0)} WPM';

  String get progressDisplay =>
      '${(gameState.boat.position * 100).toStringAsFixed(0)}%';

  String get wordsCompletedDisplay => '${gameState.wordsCompleted} words';

  bool get isBoatHit => gameState.boat.isHit;

  double get boatSpeed => gameState.boat.speed;

  double get boatPosition => gameState.boat.position;

  List<String> get upcomingWords => _upcomingWords;

  // ================== DISPOSAL ==================

  @override
  void dispose() {
    _boatAnimationTimer?.cancel();
    _wpmUpdateTimer?.cancel();
    super.dispose();
  }
}
