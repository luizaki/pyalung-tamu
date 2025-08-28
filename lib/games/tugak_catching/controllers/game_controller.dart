import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../shared/controllers/base_game_controller.dart';
import '../../shared/models/base_game_state.dart';

import '../models/frog.dart';
import '../models/question.dart';
import '../models/game_state.dart';

class TugakGameController extends BaseGameController<TugakGameState> {
  // Game data
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  final List<Offset> _lilypadPositions = [];
  List<Offset> get lilypadPositions => List.unmodifiable(_lilypadPositions);
  final Set<int> _occupiedLilypadIndices = <int>{};

  // Timers
  final Map<Frog, Timer?> _frogJumpTimers = {};

  // Constants
  static const int MAX_FROGS = 4;
  static const int MAX_LILYPADS = 8;
  static const double FROG_OFFSET = (80.0 - 60.0) / 2;

  TugakGameController() : super(TugakGameState());

  // ================== SETUPS ==================

  @override
  String getGameType() => 'tugak_catching';

  @override
  int getSecondaryScore() {
    return gameState.correctAnswers;
  }

  @override
  String getCurrentDifficulty() {
    return _currentDifficulty ?? 'beginner';
  }

  String? _currentDifficulty;

  // ================== IMPLEMENTED INITS ==================

  @override
  Future<void> initializeGameData() async {
    _questions = await QuestionBank.getQuestions();
    await _loadUserDifficulty();
  }

  Future<void> _loadUserDifficulty() async {
    _currentDifficulty = await gameService.getUserDifficulty('tugak_catching');
    notifyListeners();
  }

  @override
  Future<void> initializeGameSpecifics(Size screenSize) async {
    _generateLilypadPositions(screenSize);
    _spawnInitialFrogs();
  }

  @override
  void resetGameState() {
    gameState = TugakGameState(timeLeft: gameDuration);
  }

  // ============== IMPLEMENTED LIFECYCLES ==============

  @override
  void onGameStarted() {
    for (final frog in gameState.frogs) {
      _startFrogJumpTimer(frog);
    }
  }

  // ================ IMPLEMENTED TIMERS ================

  @override
  void pauseGameSpecificTimers() {
    for (final timer in _frogJumpTimers.values) {
      timer?.cancel();
    }
  }

  @override
  void resumeGameSpecificTimers() {
    for (final frog in gameState.frogs) {
      if (!frog.isAnswered) {
        _startFrogJumpTimer(frog);
      }
    }
  }

  @override
  void stopGameSpecificTimers() {
    _cancelAllFrogTimers();
  }

  // ==================== TUGAK INITS ====================

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

  void _spawnInitialFrogs() {
    gameState.frogs.clear();
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

        gameState.frogs.add(frog);

        _occupiedLilypadIndices.add(lilypadIndex);
        _startFrogJumpTimer(frog);
      }
    }
  }

  // =================== TUGAK TIMERS ===================

  void _startFrogJumpTimer(Frog frog) {
    final random = Random();

    // general 1-5 second interval
    final jumpInterval = 1 + random.nextInt(5);

    _frogJumpTimers[frog] = Timer.periodic(
      Duration(seconds: jumpInterval),
      (timer) {
        if (gameState.status == GameStatus.playing &&
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

    for (var frog in gameState.frogs) {
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
    for (var frog in gameState.frogs) {
      if (frog.isJumping) {
        frog.updatePosition(animationValue);
      }
    }
  }

  void _replaceFrog(Frog oldFrog) {
    if (gameState.status != GameStatus.playing) return;

    final random = Random();

    _frogJumpTimers[oldFrog]?.cancel();
    _frogJumpTimers.remove(oldFrog);

    final oldLilypadIndex = _findLilypadIndex(oldFrog);
    if (oldLilypadIndex != null) {
      _occupiedLilypadIndices.remove(oldLilypadIndex);
    }

    // remove old frog
    gameState.frogs.removeWhere((f) => f == oldFrog);

    // add new frog
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

        gameState.frogs.add(newFrog);

        _occupiedLilypadIndices.add(lilypadIndex);

        _startFrogJumpTimer(newFrog);
      }
    }

    notifyListeners();
  }

  // ================== USER INTERACTIONS ==================

  bool canTapFrog(Frog frog) {
    return gameState.status == GameStatus.playing &&
        !frog.isJumping &&
        !frog.isAnswered &&
        !frog.isBeingQuestioned;
  }

  void onAnswerSelected(Frog frog, int selectedIndex) {
    if (gameState.status != GameStatus.playing) return;

    frog.isAnswered = true;

    final isCorrect = selectedIndex == frog.question.correctIndex;

    frog.answerResult =
        isCorrect ? AnswerResult.correct : AnswerResult.incorrect;

    if (isCorrect) {
      onCorrectAnswer(points: 10);
    } else {
      onIncorrectAnswer();
    }

    gameState.frogsAnswered++;

    // create a new frog
    Timer(const Duration(seconds: 2), () {
      _replaceFrog(frog);
    });

    notifyListeners();
  }

  void onQuestionTimeout(Frog frog) {
    if (gameState.status != GameStatus.playing) return;

    frog.isAnswered = true;
    frog.isBeingQuestioned = false;
    frog.answerResult = AnswerResult.timeout;

    // update total answers
    onIncorrectAnswer();
    gameState.frogsAnswered++;

    Timer(const Duration(seconds: 1), () {
      _replaceFrog(frog);
    });

    notifyListeners();
  }
}
