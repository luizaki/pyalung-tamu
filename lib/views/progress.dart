import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '/features/progress_feature.dart';
import '/services/game_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> backgrounds = [
    'assets/bg/tugak_bgSmallFlag.PNG',
    'assets/bg/tugak_bgSmallFlag.PNG',
    'assets/bg/card_bgSmallFlag.PNG',
    'assets/bg/boat_bgSmallFlag.PNG',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgrounds[_tabController.index];
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final safeHeight = size.height - mq.padding.vertical;

    final contentWidth = (size.width * 0.68).clamp(280.0, 960.0);
    final tabFontSize = (size.width / 1280 * 12).clamp(10.0, 16.0);
    final gap = (size.height * 0.012).clamp(6.0, 16.0);

    final tabWShort = (size.width * 0.16).clamp(88.0, 220.0);
    final tabWLong = (size.width * 0.20).clamp(100.0, 260.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xAD572100),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xAD572100),
                          width: 2,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xF9DD9A00),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xAD572100),
                            width: 2,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: tabFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          SizedBox(
                              width: tabWShort,
                              child: const Tab(text: 'Overall')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Siglulung')),
                          SizedBox(
                              width: tabWShort,
                              child: const Tab(text: 'Tugak')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Mitutuglung')),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    SizedBox(
                      height: (safeHeight * 0.48).clamp(220.0, 440.0),
                      child: Container(
                        padding: EdgeInsets.all(
                            (size.width * 0.022).clamp(10.0, 24.0)),
                        decoration: BoxDecoration(
                          color: const Color(0xF9DD9A00),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xAD572100),
                            width: 4,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            _Scrollable(child: OverallProgressScreen()),
                            _Scrollable(child: SiglulungProgressScreen()),
                            _Scrollable(child: TugakProgressScreen()),
                            _Scrollable(child: MitutuglungProgressScreen()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Scrollable extends StatelessWidget {
  final Widget child;
  const _Scrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

// ================ OVERALL PROGRESS =================
class OverallProgressScreen extends StatelessWidget {
  const OverallProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();
    final scale = MediaQuery.of(context).size.width / 1280;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        gameService.fetchSiglulungStats(),
        gameService.fetchTugakStats(),
        gameService.fetchMitutuglungStats(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sig = snapshot.data![0] as SiglulungStats;
        final tug = snapshot.data![1] as TugakStats;
        final mit = snapshot.data![2] as MitutuglungStats;

        final ctrl = ProgressController()
          ..setSiglulung(sig)
          ..setTugak(tug)
          ..setMitutuglung(mit);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: StrokeText(
                    text: 'OVERALL PROGRESS',
                    textStyle: TextStyle(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFCF7D0),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 2 * scale,
                  ),
                ),
                const SizedBox(width: 12),
                BadgePill(ctrl.macro.label),
              ],
            ),
            SizedBox(height: 12 * scale),
            MacroProgressTable(
              c: ctrl,
              high: [
                (sig.wpm.toStringAsFixed(0)),
                "${tug.fluency}",
                "${mit.perfectPairs}"
              ],
              last: [
                (sig.latestWpm.toStringAsFixed(0)),
                "${tug.latestFluency}",
                "${mit.latestPerfectPairs}"
              ],
            ),
          ],
        );
      },
    );
  }
}

// ================ TUGAK CATCHING =================
class TugakProgressScreen extends StatelessWidget {
  const TugakProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();

    return FutureBuilder<TugakStats>(
      future: gameService.fetchTugakStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tug = snapshot.data!;
        final ctrl = ProgressController()..setTugak(tug);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: StrokeText(
                    text: 'TUGAK CATCHING',
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFCF7D0),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                BadgePill(ctrl.tug.badge.label),
              ],
            ),
            GameProgressCard(
              title: "Tugak Catching",
              p: ctrl.tug,
              rowLabels: const ['Fluency', 'Accuracy'],
              high: [
                "${tug.fluency} frogs",
                "${tug.accuracy.toStringAsFixed(0)}%"
              ],
              xp: [ctrl.nextTugFluency(), ctrl.nextTugAcc()],
            ),
          ],
        );
      },
    );
  }
}

// ================ MITUTUGLUNG =================
class MitutuglungProgressScreen extends StatelessWidget {
  const MitutuglungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();

    return FutureBuilder<MitutuglungStats>(
      future: gameService.fetchMitutuglungStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final mit = snapshot.data!;
        final ctrl = ProgressController()..setMitutuglung(mit);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: StrokeText(
                    text: 'MITUTUGLUNG',
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFCF7D0),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                BadgePill(ctrl.mit.badge.label),
              ],
            ),
            GameProgressCard(
              title: "Mitutuglung",
              p: ctrl.mit,
              rowLabels: const ['Perfect Matches', 'Accuracy'],
              high: [
                "${mit.perfectPairs} pairs",
                "${mit.accuracy.toStringAsFixed(0)}%"
              ],
              xp: [ctrl.nextMitPairs(), ctrl.nextMitAcc()],
            ),
          ],
        );
      },
    );
  }
}

// =============== SIGLULUNG BANGKA =================
class SiglulungProgressScreen extends StatelessWidget {
  const SiglulungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();

    return FutureBuilder<SiglulungStats>(
      future: gameService.fetchSiglulungStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sig = snapshot.data!;
        final ctrl = ProgressController()..setSiglulung(sig);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: StrokeText(
                    text: 'SIGLULUNG BANGKA',
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFCF7D0),
                    ),
                    strokeColor: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                BadgePill(ctrl.sig.badge.label),
              ],
            ),
            GameProgressCard(
              title: "Siglulung Bangka",
              p: ctrl.sig,
              rowLabels: const ['Speed', 'Accuracy'],
              high: [
                "${sig.wpm.toStringAsFixed(0)} WPM",
                "${sig.accuracy.toStringAsFixed(0)}%"
              ],
              xp: [ctrl.nextSigWpm(), ctrl.nextSigAcc()],
            ),
          ],
        );
      },
    );
  }
}
