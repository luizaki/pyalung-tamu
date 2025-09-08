import 'package:flutter/material.dart';
import '../../shared/widgets/base_start_screen.dart';

import './game_screen.dart';
import './multiplayer_screen.dart';

class MitutuglungStartScreen extends StatelessWidget {
  const MitutuglungStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartScreen(
      backgroundImage: 'assets/bg/card_bg.PNG',
      gameIcon: 'assets/icons/mitutuglung.PNG',
      color1: const Color(0xFFFF5E2D),
      color2: const Color(0xFFFF7E47),
      color3: const Color(0xFFFFAF55),
      color4: const Color(0xFFFFD859),
      gameTitle: 'Mitutuglung',
      instructions:
          'Match the Kapampangan words with the images by flipping the cards. Find all pairs to win!',
      gameScreen: const MitutuglungGameScreen(),
      gameType: 'mitutuglung',
      multiplayerBuilder: (matchId) =>
          MitutuglungMultiplayerScreen(matchId: matchId),
    );
  }
}
