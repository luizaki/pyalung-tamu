import 'package:flutter/material.dart';
import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../models/frog.dart';
import '../widgets/frog_widget.dart';
import '../widgets/lilypad.dart';
import '../widgets/question_dialog.dart';
import './multiplayer_screen.dart' show TugakMultiplayerAdapter;
import '../../../services/multiplayer_service.dart';

class TugakGameScreen extends BaseGameScreen<TugakGameController> {
  final String? multiplayerMatchId;
  final TugakMultiplayerAdapter? multiplayerAdapter;
  final Future<void> Function()? onPlayAgain;

  const TugakGameScreen({
    super.key,
    this.multiplayerMatchId,
    this.multiplayerAdapter,
    this.onPlayAgain,
  }) : super(
          isMultiplayer: multiplayerMatchId != null,
          onPlayAgain: onPlayAgain,
        );

  @override
  TugakGameScreenState createState() => TugakGameScreenState();
}

class TugakGameScreenState
    extends BaseGameScreenState<TugakGameController, TugakGameScreen> {
  late AnimationController _jumpAnimationController;
  bool _sentFinish = false;
  bool _requestedOutcome = false;

  @override
  TugakGameController createController() => TugakGameController();

  @override
  bool get isMultiplayer => widget.multiplayerMatchId != null;

  @override
  void setupController() {
    _jumpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..addListener(() {
        controller.updateFrogPositions(_jumpAnimationController.value);
        setState(() {});
      });
  }

  @override
  void onControllerUpdate() async {
    final hasJumpingFrog =
        controller.gameState.frogs.any((frog) => frog.isJumping);
    if (hasJumpingFrog && !_jumpAnimationController.isAnimating) {
      _jumpAnimationController
        ..reset()
        ..forward();
    }

    final adapter = widget.multiplayerAdapter;
    if (adapter != null) {
      final int frogs = controller.getSecondaryScore();
      final double acc =
          (controller.gameState.accuracy * 100.0).clamp(0.0, 100.0);
      adapter.updateStats(frogs: frogs, accuracy: acc);
    }

    if (controller.isGameOver &&
        !_sentFinish &&
        widget.multiplayerMatchId != null) {
      _sentFinish = true;
      final matchId = widget.multiplayerMatchId!;
      final score = controller.gameState.score;
      final acc = (controller.gameState.accuracy * 100.0).clamp(0.0, 100.0);
      final frogs = controller.getSecondaryScore();

      await MultiplayerService().submitResult(
        matchId: matchId,
        score: score,
        accuracy: acc,
        secondaryScore: frogs,
      );
      await widget.multiplayerAdapter?.finish();
    }

    if (isMultiplayer &&
        controller.isGameOver &&
        !_requestedOutcome &&
        widget.multiplayerMatchId != null) {
      _requestedOutcome = true;
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        endTitleOverride =
            await computeMultiplayerEndTitle(widget.multiplayerMatchId!);
      } catch (_) {
        endTitleOverride = null;
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void disposeGameSpecific() {
    _jumpAnimationController.dispose();
  }

  @override
  List<Widget> buildGameSpecificWidgets() {
    return [
      Positioned.fill(
        child: Image.asset('assets/bg/tugak_bg.PNG', fit: BoxFit.cover),
      ),
      Positioned.fill(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = MediaQuery.of(context).size;
              final hPad = (size.width * 0.02).clamp(8.0, 24.0);
              final vPad = (size.height * 0.02).clamp(8.0, 28.0);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ..._buildLilypads(),
                    ..._buildFrogs(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildLilypads() {
    return controller.lilypadPositions
        .map((p) => Lilypad(x: p.dx, y: p.dy))
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

      final remainingTime = controller.gameState.timeLeft < 15
          ? controller.gameState.timeLeft
          : 15;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => QuestionDialog(
          question: frog.question,
          timeoutSeconds: remainingTime,
          onAnswer: (index) {
            controller.onAnswerSelected(frog, index);
          },
          onTimeout: () {
            controller.onQuestionTimeout(frog);
          },
        ),
      ).then((_) => frog.isBeingQuestioned = false);
    }
  }
}
