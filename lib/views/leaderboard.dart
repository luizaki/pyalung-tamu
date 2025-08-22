import 'package:flutter/material.dart';

import '../widgets/main_screen.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        children: const [
          // Title
          Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
