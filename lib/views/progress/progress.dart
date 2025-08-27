import 'package:flutter/material.dart';
import 'overall_progress.dart';
import 'tugak_progress.dart';
import 'mitutuglung_progress.dart';
import 'siglulung_progress.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
                              width: tabWShort,
                              child: const Tab(text: 'Tugak')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Mitutuglung')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Siglulung')),
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
                            _Scrollable(child: TugakProgressScreen()),
                            _Scrollable(child: MitutuglungProgressScreen()),
                            _Scrollable(child: SiglulungProgressScreen()),
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
