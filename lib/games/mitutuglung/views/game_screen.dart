import 'package:flutter/material.dart';
import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../widgets/card_widget.dart';
import './multiplayer_screen.dart' show MultiplayerMitutuglungAdapter;

class MitutuglungGameScreen extends BaseGameScreen<MitutuglungGameController> {
  final String? multiplayerMatchId;
  final MultiplayerMitutuglungAdapter? multiplayerAdapter;

  const MitutuglungGameScreen({
    super.key,
    this.multiplayerMatchId,
    this.multiplayerAdapter,
  });

  @override
  MitutuglungGameScreenState createState() => MitutuglungGameScreenState();
}

class MitutuglungGameScreenState extends BaseGameScreenState<
    MitutuglungGameController, MitutuglungGameScreen> {
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
  void onControllerUpdate() {}

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

            double snapDown(double v) => (v * dpr - 0.5).floor() / dpr;

            final topPad = snapDown((size.height * 0.05).clamp(16.0, 96.0));
            final bottomPad = snapDown((size.height * 0.04).clamp(12.0, 80.0));
            final sidePad = snapDown((size.width * 0.025).clamp(8.0, 28.0));

            final availW = snapDown(
              (constraints.maxWidth - sidePad * 2)
                  .clamp(120.0, constraints.maxWidth),
            );
            final availH = snapDown(
              (constraints.maxHeight - topPad - bottomPad)
                  .clamp(120.0, constraints.maxHeight),
            );

            const double kTableCoverageW = 0.98;
            const double kTableCoverageH = 0.92;
            const double kGridCoverageW = 0.92;
            const double kGridCoverageH = 0.84;
            const double kGap = 12.0;
            const double kMinCell = 60.0;
            const double kMaxCell = 240.0;
            const double kEps = 1.0;

            final tableBoxW = snapDown(availW * kTableCoverageW);
            final tableBoxH = snapDown(availH * kTableCoverageH);

            final micro = 1.0 / dpr;
            final gridBoxW = snapDown(availW * kGridCoverageW) - micro;
            final gridBoxH = snapDown(availH * kGridCoverageH) - micro;

            final cellByW = (gridBoxW - kGap * (cols - 1)) / cols;
            final cellByH = (gridBoxH - kGap * (rows - 1)) / rows;
            final baseCell = (cellByW < cellByH ? cellByW : cellByH) - kEps;

            double cell = snapDown(baseCell.clamp(kMinCell, kMaxCell));
            double gridW = snapDown(cell * cols + kGap * (cols - 1));
            double gridH = snapDown(cell * rows + kGap * (rows - 1));

            if (gridW > gridBoxW || gridH > gridBoxH) {
              final fixW = (gridBoxW - kGap * (cols - 1)) / cols;
              final fixH = (gridBoxH - kGap * (rows - 1)) / rows;
              final corrected = (fixW < fixH ? fixW : fixH) - kEps;
              cell = snapDown(corrected.clamp(kMinCell, kMaxCell));
              gridW = snapDown(cell * cols + kGap * (cols - 1));
              gridH = snapDown(cell * rows + kGap * (rows - 1));
            }

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
                                  color:
                                      const Color(0xFF2B2B2B).withOpacity(0.15),
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
                          child: FittedBox(
                            fit: BoxFit.contain,
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
