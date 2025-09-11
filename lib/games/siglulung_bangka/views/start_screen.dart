import 'package:flutter/material.dart';
import 'package:pyalung_tamu/games/siglulung_bangka/views/multiplayer_screen.dart';
import '../../shared/widgets/base_start_screen.dart';

import './game_screen.dart';

class BangkaStartScreen extends StatelessWidget {
  const BangkaStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartScreen(
      backgroundImage: 'assets/bg/boat_bg.PNG',
      gameIcon: 'assets/icons/siglulung.PNG',
      color1: const Color(0xFF070635),
      color2: const Color(0xFF14085C),
      color3: const Color(0xFF0A0C80),
      color4: const Color(0xFF2312C0),
      gameTitle: 'Siglulung Bangka',
      instructions:
          'Type the Kapampangan words correctly to make the boat go faster! Type as many as you can before time runs out.',
      gameScreen: const BangkaGameScreen(),
      gameType: 'siglulung_bangka',
      multiplayerBuilder: (matchId) =>
          SiglulungBangkaMultiplayerScreen(matchId: matchId),
    );
  }
}
