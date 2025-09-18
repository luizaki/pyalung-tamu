import 'package:flutter/material.dart';
import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../widgets/card_widget.dart';
import './multiplayer_screen.dart' show MultiplayerMitutuglungAdapter;
import '../../../services/multiplayer_service.dart';

class MitutuglungGameScreen extends BaseGameScreen<MitutuglungGameController> {
  final String? multiplayerMatchId;
  final MultiplayerMitutuglungAdapter? multiplayerAdapter;
  final Future<void> Function()? onPlayAgain;

  const MitutuglungGameScreen({
    super.key,
    this.multiplayerMatchId,
    this.multiplayerAdapter,
    this.onPlayAgain,
  }) : super(
          isMultiplayer: multiplayerMatchId != null,
          onPlayAgain: onPlayAgain,
        );

  @override
  MitutuglungGameScreenState createState() => MitutuglungGameScreenState();
}

class MitutuglungGameScreenState extends BaseGameScreenState<
    MitutuglungGameController, MitutuglungGameScreen> {
  bool _requestedOutcome = false;
  bool _sentFinish = false;

  @override
  MitutuglungGameController createController() => MitutuglungGameController();

  @override
  bool get isMultiplayer => widget.multiplayerMatchId != null;

  @override
  void setupController() {
    //lets controller report attempts & finish, if multiplayer
    if (widget.multiplayerMatchId != null &&
        widget.multiplayerAdapter != null) {
      controller.enableMultiplayer(
        matchId: widget.multiplayerMatchId!,
        adapter: widget.multiplayerAdapter!,
      );
    }
  }

  @override
  void onControllerUpdate() async {
    if (controller.isGameOver && !_sentFinish) {
      _sentFinish = true;

      if (controller.isGameOver &&
          !_sentFinish &&
          widget.multiplayerMatchId != null) {
        final matchId = widget.multiplayerMatchId!;
        final score = controller.gameState.score;
        final acc = (controller.gameState.accuracy * 100.0).clamp(0.0, 100.0);
        final wpm = controller.getSecondaryScore();

        await MultiplayerService().submitResult(
          matchId: matchId,
          score: score,
          accuracy: acc,
          secondaryScore: wpm,
        );
        await widget.multiplayerAdapter?.finish();
      }
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
  void disposeGameSpecific() {}

  @override
  List<Widget> buildGameSpecificWidgets() {
    return [
      Positioned.fill(
        child: Image.asset('assets/bg/card_bg.PNG', fit: BoxFit.cover),
      ),
      _buildGameArea(),
    ];
  }

  Widget _buildGameArea() {
    final cardsGrid = controller.getCardsGrid();
    final rows = cardsGrid.length;
    final cols = rows == 0 ? 0 : cardsGrid.first.length;

    return Positioned.fill(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (rows == 0 || cols == 0) return const SizedBox.shrink();

            final size = MediaQuery.of(context).size;
            final dpr = MediaQuery.of(context).devicePixelRatio;

            double pxFloor(double v) => (v * dpr).floor() / dpr;

            final topPad = pxFloor((size.height * 0.05).clamp(16.0, 96.0));
            final bottomPad = pxFloor((size.height * 0.04).clamp(12.0, 80.0));
            final sidePad = pxFloor((size.width * 0.025).clamp(8.0, 28.0));

            final availW = pxFloor(
              (constraints.maxWidth - sidePad * 2)
                  .clamp(120.0, constraints.maxWidth),
            );
            final availH = pxFloor(
              (constraints.maxHeight - topPad - bottomPad)
                  .clamp(120.0, constraints.maxHeight),
            );

            const double kTableCoverageW = 0.98;
            const double kTableCoverageH = 0.92;
            const double kGridCoverageW = 0.92;
            const double kGridCoverageH = 0.84;
            const double kGap = 12.0;

            final tableBoxW = pxFloor(availW * kTableCoverageW);
            final tableBoxH = pxFloor(availH * kTableCoverageH);

            final gridBoxW = pxFloor(availW * kGridCoverageW);
            final gridBoxH = pxFloor(availH * kGridCoverageH);

            final cellW = pxFloor((gridBoxW - kGap * (cols - 1)) / cols);
            final cellH = pxFloor((gridBoxH - kGap * (rows - 1)) / rows);
            final cell = cellW < cellH ? cellW : cellH;

            final gridW = pxFloor(cell * cols + kGap * (cols - 1));
            final gridH = pxFloor(cell * rows + kGap * (rows - 1));

            return Padding(
              padding: EdgeInsets.only(
                top: topPad,
                bottom: bottomPad,
                left: sidePad,
                right: sidePad,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: availW, maxHeight: availH),
                  child: ClipRect(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Table
                        SizedBox(
                          width: tableBoxW,
                          height: tableBoxH,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              'assets/mitutuglung/Table.PNG',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, st) => Container(
                                width: tableBoxW,
                                height: tableBoxH,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B2B2B)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xAD572100),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Card grid
                        SizedBox(
                          width: gridW,
                          height: gridH,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(rows, (r) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(cols, (c) {
                                  final card = cardsGrid[r][c];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: c == cols - 1 ? 0 : kGap,
                                      bottom: r == rows - 1 ? 0 : kGap,
                                    ),
                                    child: SizedBox(
                                      width: cell,
                                      height: cell,
                                      child: CardWidget(
                                        card: card,
                                        onTap: () =>
                                            controller.onCardTapped(card),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
