import 'package:flutter/material.dart';

import '../widgets/main_screen.dart';

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
        children: [
          const Text(
            'Pyalung Tamu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Siglulung Bangka
          _buildGameCard(
              icon: Icons.directions_boat,
              title: 'Siglulung Bangka',
              onTap: () => {}),

          // Tugak Catching
          _buildGameCard(
              icon: Icons.gamepad, title: 'Tugak Catching', onTap: () => {}),

          // Mitutuglung
          _buildGameCard(
              icon: Icons.card_membership,
              title: 'Mitutuglung',
              onTap: () => {}),
        ],
      ),
    );
  }

  // Helper method for building game cards
  Widget _buildGameCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
        margin: const EdgeInsets.all(8),
        color: const Color(0xFFF4BE0A),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          highlightColor: const Color(0xFFCA8505),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, size: 32, color: Colors.brown),
              Expanded(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
              ),
            ]),
          ),
        ));
  }
}
