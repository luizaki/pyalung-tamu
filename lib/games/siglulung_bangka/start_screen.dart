import 'package:flutter/material.dart';
import '../shared/widgets/start_screen.dart';
import '../../views/home.dart';

class BangkaStartScreen extends StatelessWidget {
  const BangkaStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartScreen(
      color1: Color(0xFF070635),
      color2: Color(0xFF14085C),
      color3: Color(0xFF0A0C80),
      color4: Color(0xFF2312C0),
      gameTitle: 'Siglulung Bangka',
      instructions:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      gameScreen: HomePage(), // placeholder
    );
  }
}
