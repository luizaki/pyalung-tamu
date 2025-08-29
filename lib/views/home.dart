import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../widgets/main_screen.dart';
import '../games/games.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        contentWidthFactor: 0.70,
        children: [
          const StrokeText(
            text: 'Pyalung Tamu',
            textStyle: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Color(0xFFF4BE0A),
            ),
            strokeColor: Colors.black,
            strokeWidth: 3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            icon: Image.asset('assets/icons/siglulung.PNG',
                width: 96, height: 96),
            title: 'Siglulung Bangka',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BangkaStartScreen()),
            ),
          ),
          _buildGameCard(
            icon: Image.asset('assets/icons/tugak.PNG', width: 96, height: 96),
            title: 'Tugak Catching',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TugakStartScreen()),
            ),
          ),
          _buildGameCard(
            icon: Image.asset('assets/icons/mitutuglung.PNG',
                width: 96, height: 96),
            title: 'Mitutuglung',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MitutuglungStartScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: const Color(0xFFF4BE0A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: const Color(0xFFCA8505),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth * 0.70;
              return Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: contentWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(width: 16),
                        Expanded(
                          child: StrokeText(
                            text: title,
                            textStyle: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFCF7D0),
                            ),
                            strokeColor: Colors.black,
                            strokeWidth: 3,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
