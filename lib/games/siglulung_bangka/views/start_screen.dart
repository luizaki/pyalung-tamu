import 'package:flutter/material.dart';
import '../../shared/widgets/base_start_screen.dart';

import './game_screen.dart';

class BangkaStartScreen extends StatelessWidget {
  const BangkaStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartScreen(
      backgroundImage: 'assets/bg/boat_bg.PNG',
      gameIcon: 'assets/icons/siglulung.PNG',
      color1: Color(0xFF070635),
      color2: Color(0xFF14085C),
      color3: Color(0xFF0A0C80),
      color4: Color(0xFF2312C0),
      gameTitle: 'Siglulung Bangka',
      instructions:
          'Type the Kapampangan words correctly to make the boat go faster! Type as many as you can before time runs out.',
      gameScreen: BangkaGameScreen(),
    );
  }
}
