import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';

import '../widgets/boat_widget.dart';
import '../widgets/background.dart';
import '../widgets/word_queue.dart';

class BangkaGameScreen extends BaseGameScreen<BangkaGameController> {
  const BangkaGameScreen({super.key});

  @override
  BangkaGameScreenState createState() => BangkaGameScreenState();
}

class BangkaGameScreenState
    extends BaseGameScreenState<BangkaGameController, BangkaGameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  List<Color> get backgroundColors => const [
        Color(0xFF87CEEB),
        Color(0xFF4682B4),
      ];

  @override
  BangkaGameController createController() => BangkaGameController();

  @override
  void setupController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void onControllerUpdate() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void disposeGameSpecific() {
    _focusNode.dispose();
  }

  @override
  List<Widget> buildGameSpecificWidgets() {
    final screenSize = MediaQuery.of(context).size;

    return [
      // Moving background (full screen)
      MovingBackground(
        boatSpeed: controller.boatSpeed,
        screenSize: screenSize,
        isGameActive: controller.isGameActive,
      ),

      // Boat
      BoatWidget(
        boat: controller.gameState.boat,
        screenSize: screenSize,
      ),

      _buildWordQueueArea(),
      _buildKeyboardListener(),
    ];
  }

  Widget _buildWordQueueArea() {
    return Positioned.fill(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double topFrac = 0.10;
            const double widthFactor = 0.72;

            final double topOffset =
                (constraints.maxHeight * topFrac).clamp(64.0, 240.0);

            final double contentWidth =
                (constraints.maxWidth * widthFactor).clamp(280.0, 1100.0);

            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: topOffset),
                child: Container(
                  width: contentWidth,
                  alignment: Alignment.centerLeft,
                  child: WordQueueDisplay(
                    currentWord: controller.gameState.currentWord,
                    upcomingWords: controller.upcomingWords,
                    screenWidth: contentWidth,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyboardListener() {
    return Positioned.fill(
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final key = event.logicalKey;

            if (key == LogicalKeyboardKey.backspace) {
              controller.onKeyPressed('Backspace');
            } else if (key == LogicalKeyboardKey.enter ||
                key == LogicalKeyboardKey.space) {
              controller.onKeyPressed(' ');
            } else {
              final character = event.character;
              if (character != null && character.isNotEmpty) {
                controller.onKeyPressed(character);
              }
            }
          }
        },
        child: Container(
          color: Colors.transparent,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
