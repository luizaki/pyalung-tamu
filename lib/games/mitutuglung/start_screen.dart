import 'package:flutter/material.dart';
import '../../widgets/start_screen.dart';

class MitutuglungStartScreen extends StatelessWidget {
  const MitutuglungStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartScreen(
        color1: Color(0xFFFF5E2D),
        color2: Color(0xFFFF7E47),
        color3: Color(0xFFFFAF55),
        color4: Color(0xFFFFD859),
        gameTitle: 'Mitutuglung',
        instructions:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.');
  }
}
