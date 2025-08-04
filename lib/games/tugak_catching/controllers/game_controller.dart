import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/frog.dart';
import '../models/question.dart';
import '../models/game_state.dart';

class TugakGameController extends ChangeNotifier {
  // Game state
  TugakGameState _gameState = TugakGameState();
  TugakGameState get gameState => _gameState;

  // Game data
  List<Question> _questions = [];
  final List<Offset> _lilypadPositions = [];
  List<Offset> get lilypadPositions => List.unmodifiable(_lilypadPositions);
  final Set<int> _occupiedLilypadIndices = <int>{};

  // Timers
  Timer? _gameTimer;
  final Map<Frog, Timer?> _frogJumpTimers = {};

  // Constants
  static const int GAME_DURATION = 60;
  static const int MAX_FROGS = 4;
  static const int MAX_LILYPADS = 8;

  // Size constants
  static const double FROG_OFFSET = (80.0 - 60.0) / 2;

  TugakGameController() {
    _initializeQuestions();
  }

  // ================== INITIALIZATION ==================

  void _initializeQuestions() {
    _questions = QuestionBank.getQuestions();
  }

  void initializeGame(Size screenSize) {
    _generateLilypadPositions(screenSize);
    _resetGameState();
    _spawnInitialFrogs();
    notifyListeners();
  }

  void _generateLilypadPositions(Size screenSize) {
    _lilypadPositions.clear();

    final usableWidth = (screenSize.width * 0.8);
    final usableHeight = screenSize.height - 200;
    final marginX = (screenSize.width - usableWidth) / 2;
    const marginY = 100;

    const double minDistance = 100.0;

    // attempts to try find a usable spot
    int attempts = 0;
    const int maxAttempts = 50;

    while (_lilypadPositions.length < MAX_LILYPADS && attempts < maxAttempts) {
      final random = Random();

      // set up usable area
      final x = marginX + random.nextDouble() * (usableWidth - 80.0);
      final y = marginY + random.nextDouble() * (usableHeight - 80.0);

      final newPosition = Offset(x, y);

      // check if positon is far enough to prevent overlaps
      bool isValidPosition = true;
      for (final existingPosition in _lilypadPositions) {
        final distance = (newPosition - existingPosition).distance;
        if (distance < minDistance) {
          isValidPosition = false;
          break;
        }
      }

      if (isValidPosition) {
        _lilypadPositions.add(newPosition);
      }

      attempts++;
    }
  }

  void _resetGameState() {
    _gameState = TugakGameState(
      timeLeft: GAME_DURATION,
      status: GameStatus.playing,
    );
  }

  void _spawnInitialFrogs() {
    _gameState.frogs.clear();
    _occupiedLilypadIndices.clear();
    _cancelAllFrogTimers();

    final random = Random();
    final availableIndices =
        List.generate(_lilypadPositions.length, (index) => index);
    availableIndices.shuffle(random);

    for (int i = 0; i < MAX_FROGS; i++) {
      if (_lilypadPositions.isNotEmpty && _questions.isNotEmpty) {
        final lilypadIndex = availableIndices[i];
        final lilypad = _lilypadPositions[lilypadIndex];
        final question = _questions[random.nextInt(_questions.length)];

        final frog = Frog(
          x: lilypad.dx + FROG_OFFSET,
          y: lilypad.dy + FROG_OFFSET,
          question: question,
        );

        _gameState.frogs.add(frog);

        _occupiedLilypadIndices.add(lilypadIndex);
        _startFrogJumpTimer(frog);
      }
    }
  }

  // ================== GAME LIFECYCLE ==================

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
    startGame();
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
    _gameTimer?.cancel();
    for (final timer in _frogJumpTimers.values) {
      timer?.cancel();
    }
  }

  void _resumeTimers() {
    if (_gameState.status == GameStatus.playing) {
      _startGameTimer();
      for (final frog in _gameState.frogs) {
        if (!frog.isAnswered) {
          _startFrogJumpTimer(frog);
        }
      }
    }
  }

  void _startFrogJumpTimer(Frog frog) {
    final random = Random();

    // general 1-5 second interval
    final jumpInterval = 1 + random.nextInt(5);

    _frogJumpTimers[frog] = Timer.periodic(
      Duration(seconds: jumpInterval),
      (timer) {
        if (_gameState.status == GameStatus.playing &&
            !frog.isAnswered &&
            !frog.isJumping &&
            !frog.isBeingQuestioned) {
          _makeFrogJump(frog);

          timer.cancel();
          _startFrogJumpTimer(frog);
        }
      },
    );
  }

  void pauseFrogTimer(Frog frog) {
    _frogJumpTimers[frog]?.cancel();
    _frogJumpTimers[frog] = null;
  }

  void resumeFrogTimer(Frog frog) {
    if (!frog.isAnswered && _gameState.status == GameStatus.playing) {
      _startFrogJumpTimer(frog);
    }
  }

  void _stopAllTimers() {
    _gameTimer?.cancel();
    _cancelAllFrogTimers();
  }

  void _cancelAllFrogTimers() {
    for (final timer in _frogJumpTimers.values) {
      timer?.cancel();
    }
    _frogJumpTimers.clear();
  }

  // ================= LILYPAD MANAGEMENT =================

  List<int> _getAvailableLilypadIndices() {
    final allIndices =
        List.generate(_lilypadPositions.length, (index) => index);
    return allIndices
        .where((index) => !_occupiedLilypadIndices.contains(index))
        .toList();
  }

  int? _findLilypadIndex(Frog frog) {
    for (int i = 0; i < _lilypadPositions.length; i++) {
      final lilypad = _lilypadPositions[i];
      final expectedX = lilypad.dx + FROG_OFFSET;
      final expectedY = lilypad.dy + FROG_OFFSET;

      // find a frog at this position
      if ((frog.x - expectedX).abs() < 10 && (frog.y - expectedY).abs() < 10) {
        return i;
      }
    }
    return null;
  }

  void _updateOccupiedLilypads() {
    _occupiedLilypadIndices.clear();

    for (var frog in _gameState.frogs) {
      if (!frog.isJumping) {
        final lilypadIndex = _findLilypadIndex(frog);
        if (lilypadIndex != null) {
          _occupiedLilypadIndices.add(lilypadIndex);
        }
      } else {
        final targetLilypadIndex = _findTargetLilypadIndex(frog);
        if (targetLilypadIndex != null) {
          _occupiedLilypadIndices.add(targetLilypadIndex);
        }
      }
    }
  }

  int? _findTargetLilypadIndex(Frog frog) {
    for (int i = 0; i < _lilypadPositions.length; i++) {
      final lilypad = _lilypadPositions[i];
      final expectedX = lilypad.dx + FROG_OFFSET;
      final expectedY = lilypad.dy + FROG_OFFSET;

      if ((frog.targetX - expectedX).abs() < 10 &&
          (frog.targetY - expectedY).abs() < 10) {
        return i;
      }
    }
    return null;
  }

  // ================== FROG MANAGEMENT ==================

  void _makeFrogJump(Frog frog) {
    final random = Random();

    _updateOccupiedLilypads();
    final availableIndices = _getAvailableLilypadIndices();

    final currentLilypadIndex = _findLilypadIndex(frog);
    if (currentLilypadIndex != null) {
      availableIndices.remove(currentLilypadIndex);
    }

    if (availableIndices.isNotEmpty) {
      final newLilypadIndex =
          availableIndices[random.nextInt(availableIndices.length)];
      final newLilypad = _lilypadPositions[newLilypadIndex];

      frog.jumpTo(newLilypad.dx + FROG_OFFSET, newLilypad.dy + FROG_OFFSET);
      notifyListeners();
    }
  }

  void updateFrogPositions(double animationValue) {
    for (var frog in _gameState.frogs) {
      if (frog.isJumping) {
        frog.updatePosition(animationValue);
      }
    }
  }

  // ================== USER INTERACTIONS ==================

  bool canTapFrog(Frog frog) {
    return _gameState.status == GameStatus.playing &&
        !frog.isJumping &&
        !frog.isAnswered &&
        !frog.isBeingQuestioned;
  }

  void onAnswerSelected(Frog frog, int selectedIndex) {
    if (_gameState.status != GameStatus.playing) return;

    frog.isAnswered = true;

    final isCorrect = selectedIndex == frog.question.correctIndex;

    frog.answerResult =
        isCorrect ? AnswerResult.correct : AnswerResult.incorrect;

    if (isCorrect) {
      _gameState.score += 10;
      _gameState.correctAnswers++;
    }

    _gameState.frogsAnswered++;

    // create a new frog
    Timer(const Duration(seconds: 2), () {
      _replaceFrog(frog);
    });

    notifyListeners();
  }

  void onQuestionTimeout(Frog frog) {
    if (_gameState.status != GameStatus.playing) return;

    frog.isAnswered = true;
    frog.isBeingQuestioned = false;
    frog.answerResult = AnswerResult.timeout;

    Timer(const Duration(seconds: 1), () {
      _replaceFrog(frog);
    });

    notifyListeners();
  }

  void _replaceFrog(Frog oldFrog) {
    if (_gameState.status != GameStatus.playing) return;

    final random = Random();

    _frogJumpTimers[oldFrog]?.cancel();
    _frogJumpTimers.remove(oldFrog);

    final oldLilypadIndex = _findLilypadIndex(oldFrog);
    if (oldLilypadIndex != null) {
      _occupiedLilypadIndices.remove(oldLilypadIndex);
    }

    // Remove old frog
    _gameState.frogs.removeWhere((f) => f == oldFrog);

    // Add new frog
    if (_lilypadPositions.isNotEmpty && _questions.isNotEmpty) {
      final availableIndices = _getAvailableLilypadIndices();

      if (availableIndices.isNotEmpty) {
        final lilypadIndex =
            availableIndices[random.nextInt(availableIndices.length)];
        final lilypad = _lilypadPositions[lilypadIndex];
        final question = _questions[random.nextInt(_questions.length)];

        final newFrog = Frog(
          x: lilypad.dx + FROG_OFFSET,
          y: lilypad.dy + FROG_OFFSET,
          question: question,
        );

        _gameState.frogs.add(newFrog);

        _occupiedLilypadIndices.add(lilypadIndex);

        _startFrogJumpTimer(newFrog);
      }
    }

    notifyListeners();
  }

  // ================== GETTERS ==================

  bool get isGameActive => _gameState.status == GameStatus.playing;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;
  bool get isGamePaused => _gameState.status == GameStatus.paused;

  String get formattedTime {
    final minutes = _gameState.timeLeft ~/ 60;
    final seconds = _gameState.timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ================== CLEANUP ==================

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }
}
