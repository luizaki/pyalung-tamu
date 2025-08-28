import 'package:flutter/material.dart';
import '../../shared/widgets/base_start_screen.dart';

import './game_screen.dart';

class MitutuglungStartScreen extends StatelessWidget {
  const MitutuglungStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartScreen(
      backgroundImage: 'assets/bg/card_bg.PNG',
      gameIcon: 'assets/icons/mitutuglung.PNG',
      color1: Color(0xFFFF5E2D),
      color2: Color(0xFFFF7E47),
      color3: Color(0xFFFFAF55),
      color4: Color(0xFFFFD859),
      gameTitle: 'Mitutuglung',
      instructions:
          'Match the Kapampangan words with the images by flipping the cards. Find all pairs to win!',
      gameScreen: MitutuglungGameScreen(),
    );
  }
}
