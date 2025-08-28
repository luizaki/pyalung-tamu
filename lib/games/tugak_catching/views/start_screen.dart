import 'package:flutter/material.dart';
import '../../shared/widgets/base_start_screen.dart';
import './game_screen.dart';

class TugakStartScreen extends StatelessWidget {
  const TugakStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartScreen(
      backgroundImage: 'assets/bg/tugak_bg.PNG',
      gameIcon: 'assets/icons/tugak.PNG',
      color1: const Color(0xFF1D6DAF),
      color2: const Color(0xFF3B8DD0),
      color3: const Color(0xFF50ACF7),
      color4: const Color(0xFF70BAF7),
      gameTitle: 'Tugak Catching',
      instructions:
          'Tap the jumping frogs and answer the fill-in-the-blank Kapampangan questions with the correct tense form to win!',
      gameScreen: TugakGameScreen(),
    );
  }
}
