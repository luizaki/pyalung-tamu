import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/base_game_controller.dart';
import '../../../audio/audio_controller.dart';
import '../../../services/auth_service.dart';

abstract class BaseGameScreen<T extends BaseGameController>
    extends StatefulWidget {
  const BaseGameScreen({
    super.key,
    this.isMultiplayer = false,
    this.onPlayAgain,
  });

  final bool isMultiplayer;
  final Future<void> Function()? onPlayAgain;
}

abstract class BaseGameScreenState<T extends BaseGameController,
        U extends BaseGameScreen<T>> extends State<U>
    with TickerProviderStateMixin {
  late T controller;

  List<Color> get backgroundColors =>
      [Colors.lightBlue[200]!, Colors.blue[400]!];

  bool _isLoading = true;

  bool _showMpPauseTip = false;
  Timer? _mpTipTimer;

  @override
  void initState() {
    super.initState();

    AudioController().playGameBgm();

    controller = createController();
    setupController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final screenSize = MediaQuery.of(context).size;

      setState(() => _isLoading = true);
      await controller.initializeGame(screenSize);
      setState(() => _isLoading = false);

      controller.startCountdown();
    });

    controller.addListener(onControllerUpdate);
  }

  @override
  void dispose() {
    _mpTipTimer?.cancel();
    controller.removeListener(onControllerUpdate);
    controller.dispose();
    disposeGameSpecific();

    AudioController().playMenuBgm();

    super.dispose();
  }

  // ============== ABSTRACT METHODS ==============

  T createController();

  List<Widget> buildGameSpecificWidgets();

  void setupController();

  void onControllerUpdate();

  void disposeGameSpecific();

  bool get isMultiplayer => widget.isMultiplayer;

  // ============= COMMON UI BUIILDERS =============

  Widget _buildCountdownOverlay() {
    final size = MediaQuery.of(context).size;
    final d = (size.shortestSide * 0.35).clamp(140.0, 260.0);
    final isGo = controller.gameState.countdownValue <= 0;
    final fs = isGo ? (d * 0.42) : (d * 0.52);

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xF9DD9A00),
              border:
                  Border.all(color: const Color(0xAD572100), width: d * 0.04),
            ),
            child: Center(
              child: Text(
                controller.gameState.countdownValue > 0
                    ? '${controller.gameState.countdownValue}'
                    : 'GO!',
                key: ValueKey(controller.gameState.countdownValue),
                style: TextStyle(
                  fontSize: fs * 0.75,
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
    final size = MediaQuery.of(context).size;
    final topPad = (size.height * 0.03).clamp(12.0, 40.0);
    final boxW = (size.width * 0.12).clamp(140.0, 280.0);
    final borderW = (boxW * 0.012).clamp(3.0, 6.0);

    return Positioned(
      top: topPad,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: boxW,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xF9DD9A00),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xAD572100), width: borderW),
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
        fontSize: 14,
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
        fontSize: 12,
        color: controller.gameState.timeLeft <= 10 ? Colors.red : Colors.brown,
      ),
    );
  }

  Widget _buildPauseButton() {
    final size = MediaQuery.of(context).size;
    final top = (size.height * 0.03).clamp(12.0, 40.0);
    final left = (size.width * 0.03).clamp(12.0, 40.0);
    final d = (size.shortestSide * 0.08).clamp(44.0, 64.0);
    final bw = (d * 0.08).clamp(3.0, 5.0);

    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xAD572100), width: bw),
        ),
        child: IconButton(
          icon: const Icon(Icons.pause, color: Colors.brown),
          onPressed: () {
            if (isMultiplayer) {
              _showMpPauseHint();
            } else {
              controller.pauseGame();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMultiplayerPauseTip() {
    final size = MediaQuery.of(context).size;
    final top = (size.height * 0.03).clamp(8.0, 32.0);
    final left = (size.width * 0.03).clamp(8.0, 32.0);
    return Positioned(
      top: top,
      left: left + 64,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xF9DD9A00),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xAD572100), width: 2),
          ),
          child: const Text(
            'Pausing is not allowed during multiplayer matches.',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 8,
            ),
          ),
        ),
      ),
    );
  }

  void _showMpPauseHint() {
    _mpTipTimer?.cancel();
    setState(() => _showMpPauseTip = true);
    _mpTipTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showMpPauseTip = false);
    });
  }

  Widget _buildPauseOverlay() {
    final size = MediaQuery.of(context).size;
    final maxW = (size.width * 0.55).clamp(280.0, size.width * 0.9);
    final maxH = (size.height * 0.85);

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF9DD9A00),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xAD572100), width: 5),
              ),
              child: SingleChildScrollView(
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

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        // Exit
                        ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverDialog() {
    final authService = AuthService();
    final isGuest = authService.isGuest;

    final size = MediaQuery.of(context).size;
    final maxW = (size.width * 0.32).clamp(280.0, size.width * 0.9);
    final maxH = size.height * 0.85;

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF9DD9A00),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xAD572100), width: 5),
              ),
              child: SingleChildScrollView(
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

                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        // Exit
                        ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
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
                          onPressed: () async {
                            if (isMultiplayer) {
                              if (widget.onPlayAgain != null) {
                                await widget.onPlayAgain!();
                              } else {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              }
                            } else {
                              final screenSize = MediaQuery.of(context).size;
                              controller.restartGame(screenSize);
                            }
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
    if (controller.newDifficulty == null ||
        controller.previousDifficulty == null ||
        controller.newDifficulty == controller.previousDifficulty) {
      return const SizedBox.shrink();
    }

    final isLevelUp = _getDifficultyLevel(controller.newDifficulty!) >
        _getDifficultyLevel(controller.previousDifficulty!);

    final changeText = isLevelUp
        ? 'Question difficulty increased! ${_capitalizeDifficulty(controller.previousDifficulty)} → ${_capitalizeDifficulty(controller.newDifficulty)}'
        : 'Question difficulty decreased! ${_capitalizeDifficulty(controller.previousDifficulty)} → ${_capitalizeDifficulty(controller.newDifficulty)}';

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
              'Create an account/login to save your progress and answer harder questions!',
              style: TextStyle(
                color: Color(0xFF4A2C17),
                fontSize: 13,
                fontWeight: FontWeight.w300,
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

                // pause button always visible; disabled in multiplayer
                _buildPauseButton(),
                if (_showMpPauseTip) _buildMultiplayerPauseTip(),
                if (!isMultiplayer && controller.isGamePaused)
                  _buildPauseOverlay(),

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
