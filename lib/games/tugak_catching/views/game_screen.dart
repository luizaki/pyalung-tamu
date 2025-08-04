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
      _controller.startGame();
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
                _buildGameUI(_controller),
                _buildBackButton(),
                if (_controller.isGameOver) _buildGameOverDialog(_controller),
              ],
            ),
          );
        },
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

  Widget _buildGameUI(TugakGameController controller) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreWidget(controller.gameState.score),
          _buildTimeWidget(
              controller.formattedTime, controller.gameState.timeLeft),
        ],
      ),
    );
  }

  Widget _buildScoreWidget(int score) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Score: $score',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeWidget(String timeText, int timeLeft) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Time: $timeText',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: timeLeft <= 10 ? Colors.red : Colors.black,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildGameOverDialog(TugakGameController controller) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: AlertDialog(
            title: const Text('Game Over!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Final Score: ${controller.gameState.score}'),
                Text(
                    'Accuracy: ${(controller.gameState.accuracy * 100).toStringAsFixed(1)}%'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Menu'),
              ),
              TextButton(
                onPressed: () {
                  final screenSize = MediaQuery.of(context).size;
                  controller.restartGame(screenSize);
                },
                child: const Text('Play Again'),
              ),
            ],
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
