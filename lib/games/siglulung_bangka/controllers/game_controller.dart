import 'dart:async';
import 'package:flutter/material.dart';

import '../../shared/controllers/base_game_controller.dart';
import '../../shared/models/base_game_state.dart';

import '../models/game_state.dart';
import '../models/boat.dart';
import '../models/word.dart';
import '../models/word_bank.dart';

import '../../../services/game_service.dart';

class BangkaGameController extends BaseGameController<BangkaGameState> {
  // Game data
  List<WordData> _upcomingWords = [];

  // Game configs
  static const boatUpdateInterval = 8;
  static const wpmUpdateInterval = 300;

  // Timers
  Timer? _boatAnimationTimer;
  Timer? _wpmUpdateTimer;

  BangkaGameController() : super(BangkaGameState());

  // ================== SETUPS ==================

  @override
  String getGameType() => 'siglulung_bangka';

  @override
  int getSecondaryScore() {
    final timeElapsed = (gameDuration - gameState.timeLeft);
    if (timeElapsed <= 0) return 0;

    final wpm = (gameState.correctAnswers * 60) ~/ timeElapsed;
    return wpm;
  }

  @override
  String getCurrentDifficulty() {
    return _currentDifficulty ?? 'beginner';
  }

  String? _currentDifficulty;

  // ================== IMPLEMENTED INITS ==================

  @override
  Future<void> initializeGameData() async {
    gameState.wordBank =
        await WordBank.getWords(difficulty: getCurrentDifficulty());
    await _loadUserDifficulty();
  }

  Future<void> _loadUserDifficulty() async {
    _currentDifficulty =
        await gameService.getUserDifficulty('siglulung_bangka');
    notifyListeners();
  }

  @override
  Future<void> initializeGameSpecifics(Size screenSize) async {
    await _resetGameSpecifics();
    await _generateFirstWord();
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

  Future<void> _resetGameSpecifics() async {
    gameState.currentWord = null;
    gameState.completedWords.clear();
    gameState.boat = Boat();
    gameState.totalCharacters = 0;
    gameState.correctCharacters = 0;
    gameState.currentWPM = 0.0;
    gameState.gameStartTime = null;

    await _generateWordQueue();
  }

  Future<void> _generateWordQueue() async {
    _upcomingWords = await WordBank.getRandomWords(getCurrentDifficulty(), 10);
  }

  Future<void> _generateFirstWord() async {
    if (_upcomingWords.isNotEmpty) {
      final word = _upcomingWords.removeAt(0);
      gameState.currentWord =
          TypedWord(word: word.baseForm, translation: word.englishTrans);

      // Refill queue if running low
      if (_upcomingWords.length < 5) {
        _upcomingWords
            .addAll(await WordBank.getRandomWords(getCurrentDifficulty(), 5));
      }

      notifyListeners();
    }
  }

  void _generateNextWord() async {
    if (_upcomingWords.isNotEmpty && isGameActive) {
      final word = _upcomingWords.removeAt(0);
      gameState.currentWord =
          TypedWord(word: word.baseForm, translation: word.englishTrans);

      // Keep queue filled
      if (_upcomingWords.length < 5) {
        _upcomingWords
            .addAll(await WordBank.getRandomWords(getCurrentDifficulty(), 5));
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
    } else if (key == 'Enter') {
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

    if (currentWord.typedText == currentWord.word) {
      const Map<String, double> multipliers = {
        'beginner': 1.0,
        'intermediate': 1.5,
        'advanced': 2.0,
      };

      int points = (currentWord.word.length.clamp(1, 5)) * 2;

      onCorrectAnswer(
          points:
              (points * (multipliers[getCurrentDifficulty()] ?? 1.0)).round());
    } else {
      gameState.boat.hit();
    }

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

  String get progressDisplay =>
      '${(gameState.boat.position * 100).toStringAsFixed(0)}%';

  bool get isBoatHit => gameState.boat.isHit;

  double get boatSpeed => gameState.boat.speed;

  double get boatPosition => gameState.boat.position;

  List<WordData> get upcomingWords => _upcomingWords;

  // ================== DISPOSAL ==================

  @override
  void dispose() {
    _boatAnimationTimer?.cancel();
    _wpmUpdateTimer?.cancel();
    super.dispose();
  }
}
