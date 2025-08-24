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
  List<Color> get backgroundColors => [
        const Color(0xFF87CEEB),
        const Color(0xFF4682B4),
      ];

  @override
  BangkaGameController createController() {
    return BangkaGameController();
  }

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
      // Moving background
      MovingBackground(
        boatSpeed: controller.boatSpeed,
        screenSize: screenSize,
      ),

      // Boat
      BoatWidget(
        boat: controller.gameState.boat,
        screenSize: screenSize,
      ),

      // Word queue display
      _buildWordQueueArea(screenSize),

      // Game stats
      _buildGameStats(screenSize),

      // Keyboard listener
      _buildKeyboardListener(),
    ];
  }

  Widget _buildWordQueueArea(Size screenSize) {
    return Positioned(
      top: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: screenSize.width * 0.8,
          alignment: Alignment.centerLeft,
          child: WordQueueDisplay(
            currentWord: controller.gameState.currentWord,
            upcomingWords: controller.upcomingWords,
            screenWidth: screenSize.width,
          ),
        ),
      ),
    );
  }

  Widget _buildGameStats(Size screenSize) {
    return Positioned(
      top: 30,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xAD572100), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              controller.wpmDisplay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.wordsCompletedDisplay,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.brown,
              ),
            ),
          ],
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
