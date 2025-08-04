import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/frog.dart';
import '../widgets/frog_widget.dart';
import '../widgets/lilypad.dart';
import '../widgets/question_dialog.dart';

class TugakGameScreen extends StatefulWidget {
  @override
  TugakGameScreenState createState() => TugakGameScreenState();
}

class TugakGameScreenState extends State<TugakGameScreen>
    with TickerProviderStateMixin {
  late TugakGameController _controller;
  late AnimationController _jumpAnimationController;

  @override
  void initState() {
    super.initState();

    _jumpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _controller = TugakGameController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      _controller.initializeGame(screenSize);
      _controller.startCountdown();
    });

    _jumpAnimationController.addListener(() {
      _controller.updateFrogPositions(_jumpAnimationController.value);
      setState(() {});
    });

    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    final hasJumpingFrog =
        _controller.gameState.frogs.any((frog) => frog.isJumping);

    if (hasJumpingFrog && !_jumpAnimationController.isAnimating) {
      _jumpAnimationController.reset();
      _jumpAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue[200]!, Colors.blue[400]!],
              ),
            ),
            child: Stack(
              children: [
                ..._buildLilypads(),
                ..._buildFrogs(),
                _buildGameUI(),
                if (_controller.isGamePaused) _buildPauseOverlay(),
                _buildPauseButton(),
                if (_controller.isGameOver) _buildGameOverDialog(),
                if (_controller.gameState.isCountingDown)
                  _buildCountdownOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xF9DD9A00),
              border: Border.all(color: const Color(0xAD572100), width: 8),
            ),
            child: Center(
              child: Text(
                _controller.gameState.countdownValue > 0
                    ? '${_controller.gameState.countdownValue}'
                    : 'GO!',
                key: ValueKey(_controller.gameState.countdownValue),
                style: TextStyle(
                  fontSize: _controller.gameState.countdownValue > 0 ? 72 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLilypads() {
    return _controller.lilypadPositions
        .map((position) => Lilypad(x: position.dx, y: position.dy))
        .toList();
  }

  List<Widget> _buildFrogs() {
    return _controller.gameState.frogs
        .map((frog) => FrogWidget(
              frog: frog,
              onTap: () => _onFrogTapped(frog),
            ))
        .toList();
  }

  Widget _buildGameUI() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 1 / 6,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xF9DD9A00),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xAD572100), width: 5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreWidget(_controller.gameState.score),
              const SizedBox(height: 3),

              // Divider
              Container(
                height: 2,
                width: double.infinity,
                color: const Color(0xAD572100),
              ),

              const SizedBox(height: 5),
              _buildTimeWidget(
                  _controller.formattedTime, _controller.gameState.timeLeft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreWidget(int score) {
    return Text(
      'Score: $score pts',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }

  Widget _buildTimeWidget(String timeText, int timeLeft) {
    return Text(
      timeText,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: timeLeft <= 10 ? Colors.red : Colors.brown,
      ),
    );
  }

  Widget _buildPauseButton() {
    return Positioned(
      top: 30,
      left: 30,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xAD572100), width: 4),
        ),
        child: IconButton(
          icon: const Icon(Icons.pause, color: Colors.brown),
          onPressed: () {
            if (_controller.isGamePaused) {
              _controller.resumeGame();
            } else {
              _controller.pauseGame();
            }
          },
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 1 / 4,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF9DD9A00),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xAD572100), width: 5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Paused',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Divider
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: const Color(0xAD572100),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Click the pause button to resume',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildGameOverDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 1 / 4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xF9DD9A00),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xAD572100), width: 5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over title
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 10),

                // Divider
                Container(
                  height: 2,
                  width: double.infinity,
                  color: const Color(0xAD572100),
                ),
                const SizedBox(height: 10),

                // Score
                Text(
                  'Final Score: ${_controller.gameState.score}',
                  style: const TextStyle(
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),

                // Accuracy
                Text(
                    'Accuracy: ${(_controller.gameState.accuracy * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.brown,
                    )),
                const SizedBox(height: 20),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Back to Menu'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final screenSize = MediaQuery.of(context).size;
                          _controller.restartGame(screenSize);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Play Again'),
                      ),
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFrogTapped(Frog frog) {
    if (_controller.canTapFrog(frog)) {
      frog.isBeingQuestioned = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => QuestionDialog(
          question: frog.question,
          onAnswer: (index) {
            frog.isBeingQuestioned = false;
            _controller.onAnswerSelected(frog, index);
          },
          onTimeout: () {
            frog.isBeingQuestioned = false;
            _controller.onQuestionTimeout(frog);
          },
        ),
      ).then((_) {
        frog.isBeingQuestioned = false;
      });
    }
  }

  @override
  void dispose() {
    _jumpAnimationController.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }
}
