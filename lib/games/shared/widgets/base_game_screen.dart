import 'package:flutter/material.dart';
import '../controllers/base_game_controller.dart';

import '../../../services/auth_service.dart';

abstract class BaseGameScreen<T extends BaseGameController>
    extends StatefulWidget {
  const BaseGameScreen({super.key});
}

abstract class BaseGameScreenState<T extends BaseGameController,
        U extends BaseGameScreen<T>> extends State<U>
    with TickerProviderStateMixin {
  late T controller;

  List<Color> get backgroundColors =>
      [Colors.lightBlue[200]!, Colors.blue[400]!];

  @override
  void initState() {
    super.initState();

    controller = createController();
    setupController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      controller.initializeGame(screenSize);
      controller.startCountdown();
    });

    controller.addListener(onControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(onControllerUpdate);
    controller.dispose();
    disposeGameSpecific();
    super.dispose();
  }

  // ============== ABSTRACT METHODS ==============

  T createController();

  List<Widget> buildGameSpecificWidgets();

  void setupController();

  void onControllerUpdate();

  void disposeGameSpecific();

  // ============= COMMON UI BUIILDERS =============

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
                controller.gameState.countdownValue > 0
                    ? '${controller.gameState.countdownValue}'
                    : 'GO!',
                key: ValueKey(controller.gameState.countdownValue),
                style: TextStyle(
                  fontSize: controller.gameState.countdownValue > 0 ? 72 : 48,
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
              _buildScoreWidget(),
              const SizedBox(height: 3),

              // Divider
              Container(
                height: 2,
                width: double.infinity,
                color: const Color(0xAD572100),
              ),

              const SizedBox(height: 5),
              _buildTimeWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreWidget() {
    return Text(
      'Score: ${controller.getSecondaryScore()} ${_getSecondaryScoreLabel()}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }

  String _getSecondaryScoreLabel() {
    switch (controller.getGameType()) {
      case 'siglulung_bangka':
        return 'WPM';
      case 'tugak_catching':
        return 'Frogs';
      case 'mitutuglung':
        return 'Pairs';
      default:
        return 'Score';
    }
  }

  Widget _buildTimeWidget() {
    return Text(
      controller.formattedTime,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: controller.gameState.timeLeft <= 10 ? Colors.red : Colors.brown,
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
            controller.pauseGame();
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
              width: MediaQuery.of(context).size.width * 2 / 5,
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
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Exit
                      ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Exit Game'),
                      ),

                      // Restart
                      ElevatedButton(
                        onPressed: () {
                          final screenSize = MediaQuery.of(context).size;
                          controller.restartGame(screenSize);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Restart Game'),
                      ),

                      // Resume
                      ElevatedButton(
                        onPressed: () {
                          controller.resumeGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Resume Game'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildGameOverDialog() {
    final authService = AuthService();
    final isGuest = authService.isGuest;

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

                // Accuracy
                _buildStatRow(
                  'Accuracy:',
                  '${(controller.gameState.accuracy * 100).toStringAsFixed(1)}%',
                  Icons.my_location,
                ),

                // Secondary score
                _buildStatRow(
                  '${_getSecondaryScoreLabel()}:',
                  '${controller.getSecondaryScore()}',
                  _getSecondaryScoreIcon(),
                ),

                // Points and difficulty for non-guest
                if (!isGuest) ...[
                  _buildStatRow(
                    'Points:',
                    '${controller.gameState.score} pts',
                    Icons.stars,
                  ),

                  // Show if they leveled up
                  if (controller.difficultyChanged)
                    _buildDifficultyChangeWidget(),
                ],

                // Guest login reminder
                if (isGuest) _buildGuestMessage(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Exit
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
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

                    // Play again
                    ElevatedButton(
                      onPressed: () {
                        final screenSize = MediaQuery.of(context).size;
                        controller.restartGame(screenSize);
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChangeWidget() {
    final isLevelUp = controller.newDifficulty != null &&
        controller.previousDifficulty != null &&
        _getDifficultyLevel(controller.newDifficulty!) >
            _getDifficultyLevel(controller.previousDifficulty!);

    final changeText = isLevelUp
        ? 'Level Up! ${_capitalizeDifficulty(controller.previousDifficulty)} → ${_capitalizeDifficulty(controller.newDifficulty)}'
        : 'Level Down: ${_capitalizeDifficulty(controller.previousDifficulty)} → ${_capitalizeDifficulty(controller.newDifficulty)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLevelUp
            ? const Color(0xFFD4A574).withValues(alpha: 0.4)
            : const Color(0xFFB8860B).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLevelUp ? const Color(0xFF8B4513) : const Color(0xAD572100),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLevelUp ? Icons.trending_up : Icons.trending_down,
            color:
                isLevelUp ? const Color(0xFF8B4513) : const Color(0xAD572100),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              changeText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLevelUp
                    ? const Color(0xFF4A2C17)
                    : const Color(0xFF2D1810),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeDifficulty(String? difficulty) {
    if (difficulty == null || difficulty.isEmpty) return '';
    return difficulty[0].toUpperCase() + difficulty.substring(1);
  }

  Widget _buildGuestMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xAD572100), width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Color(0xAD572100), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Create an account to save your progress and track improvements!',
              style: TextStyle(
                color: Color(0xFF4A2C17),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSecondaryScoreIcon() {
    switch (controller.getGameType()) {
      case 'siglulung_bangka':
        return Icons.speed;
      case 'tugak_catching':
        return Icons.catching_pokemon;
      case 'mitutuglung':
        return Icons.extension;
      default:
        return Icons.score;
    }
  }

  int _getDifficultyLevel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 1;
    }
  }

  // ================ MAIN BUILDER ================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: backgroundColors,
              ),
            ),
            child: Stack(
              children: [
                ...buildGameSpecificWidgets(),
                _buildGameUI(),

                // TODO: might need to remove pausing if multiplayer is implemented
                _buildPauseButton(),
                if (controller.isGamePaused) _buildPauseOverlay(),

                if (controller.isGameOver) _buildGameOverDialog(),

                if (controller.gameState.isCountingDown)
                  _buildCountdownOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
}
