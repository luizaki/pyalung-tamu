import 'package:flutter/material.dart';
import '../../widgets/main_screen.dart';
import 'overall_progress.dart';
import 'tugak_progress.dart';
import 'mitutuglung_progress.dart';
import 'siglulung_progress.dart';

class ProgressBox extends StatelessWidget {
  final List<Widget> children;
  const ProgressBox({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 5,
          child: Container(
            margin: const EdgeInsets.only(top: 100, left: 32, right: 32),
            decoration: BoxDecoration(
              color: const Color(0xF9DD9A00),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xAD572100),
                width: 10,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xAD572100).withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final Widget child;
  const ProgressCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xAD572100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xAD572100), width: 2),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: const Color(0xF9DD9A00),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xAD572100), width: 2),
              ),
              labelStyle: const TextStyle(
                fontFamily:
                    'PressStart2P', //pixel font, pero parang ayaw gumana
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
          Expanded(
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
        ],
      ),
    );
  }
}
