import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../widgets/card_widget.dart';
import './multiplayer_screen.dart' show MultiplayerMitutuglungAdapter;

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
  final _sb = Supabase.instance.client;
  String? _endTitle;
  bool _requestedOutcome = false;

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
    if (isMultiplayer &&
        controller.isGameOver &&
        !_requestedOutcome &&
        widget.multiplayerMatchId != null) {
      _requestedOutcome = true;
      _endTitle = await _resolveOutcomeTitle(widget.multiplayerMatchId!);
      if (mounted) setState(() {});
    }
  }

  @override
  void disposeGameSpecific() {}

  Future<String> _resolveOutcomeTitle(String matchId) async {
    try {
      final uid = _sb.auth.currentUser?.id;
      if (uid == null) return 'Match Complete!';

      int? myScore, oppScore;
      double? myAcc, oppAcc;

      final res = await _sb
          .from('multiplayer_results')
          .select('user_id, score, accuracy')
          .eq('match_id', matchId);

      if (res is List && res.isNotEmpty) {
        for (final r in res) {
          final isMe = r['user_id'] == uid;
          final s = (r['score'] as num?)?.toInt() ?? 0;
          final a = (r['accuracy'] as num?)?.toDouble() ?? 0.0;
          if (isMe) {
            myScore = s;
            myAcc = a;
          } else {
            oppScore = s;
            oppAcc = a;
          }
        }
      }

      if (myScore == null || oppScore == null) {
        final live = await _sb
            .from('multiplayer_live')
            .select('user_id, pairs, accuracy')
            .eq('match_id', matchId);

        if (live is List) {
          for (final r in live) {
            final isMe = r['user_id'] == uid;
            final s = (r['pairs'] as num?)?.toInt() ?? 0;
            final a = (r['accuracy'] as num?)?.toDouble() ?? 0.0;
            if (isMe) {
              myScore ??= s;
              myAcc ??= a;
            } else {
              oppScore ??= s;
              oppAcc ??= a;
            }
          }
        }
      }

      final m = myScore ?? 0;
      final o = oppScore ?? 0;
      if (m > o) return 'You Win!';
      if (m < o) return 'You Lose!';
      if (myAcc != null && oppAcc != null) {
        if (myAcc > oppAcc) return 'You Win!';
        if (myAcc < oppAcc) return 'You Lose!';
      }
      return 'Tie!';
    } catch (_) {
      return 'Match Complete!';
    }
  }

  @override
  String getEndTitle() =>
      _endTitle ?? (isMultiplayer ? 'Match Complete!' : 'Game Over!');

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
