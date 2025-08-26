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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(bg, fit: BoxFit.cover),
          ),
          Center(
            child: SizedBox(
              width: screenWidth * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xAD572100),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xAD572100), width: 2),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xF9DD9A00),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xAD572100), width: 2),
                      ),
                      labelStyle: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      tabs: const [
                        SizedBox(width: 100, child: Tab(text: 'Overall')),
                        SizedBox(width: 100, child: Tab(text: 'Tugak')),
                        SizedBox(width: 120, child: Tab(text: 'Mitutuglung')),
                        SizedBox(width: 120, child: Tab(text: 'Siglulung')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xF9DD9A00),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xAD572100), width: 8),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          OverallProgressScreen(),
                          TugakProgressScreen(),
                          MitutuglungProgressScreen(),
                          SiglulungProgressScreen(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
