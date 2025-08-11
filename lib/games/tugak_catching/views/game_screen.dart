import 'package:flutter/material.dart';

import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../models/frog.dart';
import '../widgets/frog_widget.dart';
import '../widgets/lilypad.dart';
import '../widgets/question_dialog.dart';

class TugakGameScreen extends BaseGameScreen<TugakGameController> {
  const TugakGameScreen({super.key});

  @override
  TugakGameScreenState createState() => TugakGameScreenState();
}

class TugakGameScreenState
    extends BaseGameScreenState<TugakGameController, TugakGameScreen> {
  late AnimationController _jumpAnimationController;

  @override
  TugakGameController createController() {
    return TugakGameController();
  }

  @override
  void setupController() {
    _jumpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _jumpAnimationController.addListener(() {
      controller.updateFrogPositions(_jumpAnimationController.value);
      setState(() {});
    });
  }

  @override
  void onControllerUpdate() {
    final hasJumpingFrog =
        controller.gameState.frogs.any((frog) => frog.isJumping);

    if (hasJumpingFrog && !_jumpAnimationController.isAnimating) {
      _jumpAnimationController.reset();
      _jumpAnimationController.forward();
    }
  }

  @override
  void disposeGameSpecific() {
    _jumpAnimationController.dispose();
  }

  @override
  List<Widget> buildGameSpecificWidgets() {
    return [
      ..._buildLilypads(),
      ..._buildFrogs(),
    ];
  }

  List<Widget> _buildLilypads() {
    return controller.lilypadPositions
        .map((position) => Lilypad(x: position.dx, y: position.dy))
        .toList();
  }

  List<Widget> _buildFrogs() {
    return controller.gameState.frogs
        .map((frog) => FrogWidget(
              frog: frog,
              onTap: () => _onFrogTapped(frog),
            ))
        .toList();
  }

  void _onFrogTapped(Frog frog) {
    if (controller.canTapFrog(frog)) {
      frog.isBeingQuestioned = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => QuestionDialog(
          question: frog.question,
          onAnswer: (index) {
            frog.isBeingQuestioned = false;
            controller.onAnswerSelected(frog, index);
          },
          onTimeout: () {
            frog.isBeingQuestioned = false;
            controller.onQuestionTimeout(frog);
          },
        ),
      ).then((_) {
        frog.isBeingQuestioned = false;
      });
    }
  }
}
