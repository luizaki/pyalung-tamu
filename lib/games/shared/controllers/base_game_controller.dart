import 'dart:async';
import 'package:flutter/material.dart';

import '../models/base_game_state.dart';
import '../../../services/game_service.dart';

abstract class BaseGameController<T extends BaseGameState>
    extends ChangeNotifier {
  T _gameState;
  T get gameState => _gameState;
  set gameState(T newState) => _gameState = newState;

  final GameService _gameService = GameService();

  // Timers
  Timer? _countdownTimer;
  Timer? _gameTimer;

  // Game configs
  int get gameDuration => 60;
  int get countdownStart => 3;

  BaseGameController(this._gameState);

  // ================== INITIALIZATION ==================

  void initializeGame(Size screenSize) {
    initializeGameData();
    resetGameState();
    initializeGameSpecifics(screenSize);
    notifyListeners();
  }

  // ================== GAME LIFECYCLE ==================

  void startCountdown() {
    _gameState.isCountingDown = true;
    _gameState.countdownValue = countdownStart;
    _gameState.status = GameStatus.menu;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.countdownValue > 0) {
        _gameState.countdownValue--;
        notifyListeners();
      } else {
        timer.cancel();
        _gameState.isCountingDown = false;
        _gameState.status = GameStatus.playing;
        _startGameTimer();
        onGameStarted();
        notifyListeners();
      }
    });
  }

  void startGame() {
    _gameState.status = GameStatus.playing;
    _startGameTimer();
    notifyListeners();
  }

  void pauseGame() {
    _gameState.status = GameStatus.paused;
    _pauseTimers();
    notifyListeners();
  }

  void resumeGame() {
    _gameState.status = GameStatus.playing;
    _resumeTimers();
    notifyListeners();
  }

  void endGame() {
    _gameState.status = GameStatus.gameOver;
    _stopAllTimers();
    notifyListeners();
  }

  void restartGame(Size screenSize) {
    _stopAllTimers();
    initializeGame(screenSize);
    startCountdown();
  }

  // ================== TIMER MANAGEMENT ==================

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.status == GameStatus.playing) {
        _gameState.timeLeft--;
        if (_gameState.timeLeft <= 0) {
          endGame();
        } else {
          notifyListeners();
        }
      }
    });
  }

  void _pauseTimers() {
    pauseGameTimer();
    pauseGameSpecificTimers();
  }

  void _resumeTimers() {
    if (_gameState.status == GameStatus.playing) {
      _startGameTimer();
      resumeGameSpecificTimers();
    }
  }

  void _stopAllTimers() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    stopGameSpecificTimers();
  }

  // public start timer variant
  void startGameTimer() {
    _startGameTimer();
  }

  void pauseGameTimer() {
    _gameTimer?.cancel();
  }

  void resumeGameTimer() {
    if (_gameState.status == GameStatus.playing && _gameState.timeLeft > 0) {
      _startGameTimer();
    }
  }

  // ============== ANSWER HANDLING ==============

  void onCorrectAnswer({int points = 10}) {
    _gameState.score += points;
    _gameState.correctAnswers++;
    _gameState.totalAnswers++;
    notifyListeners();
  }

  void onIncorrectAnswer() {
    _gameState.totalAnswers++;
    notifyListeners();
  }

  // ================= FINISHING =================

  Future<void> saveGameResults() async {
    await _gameService.saveGameScore(
      gameType: getGameType(),
      accuracy: (gameState.accuracy * 100).round(),
      secondaryScore: getSecondaryScore(),
      score: gameState.score,
      difficulty: getCurrentDifficulty(),
    );
  }

  // ============== ABSTRACT METHODS ==============

  void initializeGameData();

  void initializeGameSpecifics(Size screenSize);

  void resetGameState();

  void onGameStarted();

  void pauseGameSpecificTimers();

  void resumeGameSpecificTimers();

  void stopGameSpecificTimers();

  String getGameType();

  int getSecondaryScore();

  String getCurrentDifficulty();

  // ================== GETTERS ==================

  bool get isGameActive => _gameState.status == GameStatus.playing;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;
  bool get isGamePaused => _gameState.status == GameStatus.paused;

  String get formattedTime {
    final minutes = _gameState.timeLeft ~/ 60;
    final seconds = _gameState.timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ================== CLEANUP ==================

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }
}
