import 'package:flutter/material.dart';
import '../../shared/widgets/start_screen.dart';
import './game_screen.dart';

class TugakStartScreen extends StatelessWidget {
  const TugakStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartScreen(
      color1: const Color(0xFF1D6DAF),
      color2: const Color(0xFF3B8DD0),
      color3: const Color(0xFF50ACF7),
      color4: const Color(0xFF70BAF7),
      gameTitle: 'Tugak Catching',
      instructions:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      gameScreen: TugakGameScreen(),
    );
  }
}
