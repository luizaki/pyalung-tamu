import 'package:flutter/material.dart';

import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';
import '../widgets/card_widget.dart';

class MitutuglungGameScreen extends BaseGameScreen<MitutuglungGameController> {
  const MitutuglungGameScreen({super.key});

  @override
  MitutuglungGameScreenState createState() => MitutuglungGameScreenState();
}

class MitutuglungGameScreenState extends BaseGameScreenState<
    MitutuglungGameController, MitutuglungGameScreen> {
  @override
  MitutuglungGameController createController() {
    return MitutuglungGameController();
  }

  @override
  void setupController() {}

  @override
  void onControllerUpdate() {}

  @override
  void disposeGameSpecific() {}

  @override
  List<Widget> buildGameSpecificWidgets() {
    return [
      Positioned.fill(
        child: Image.asset(
          'assets/bg/card_bg.PNG',
          fit: BoxFit.cover,
        ),
      ),
      _buildGameArea(),
    ];
  }

  Widget _buildGameArea() {
    final cardsGrid = controller.getCardsGrid();

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      bottom: 50,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/mitutuglung/Table.PNG',
              fit: BoxFit.contain,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cardsGrid.map((row) => _buildCardRow(row)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRow(List<dynamic> cards) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards
          .map((card) => CardWidget(
                card: card,
                onTap: () => controller.onCardTapped(card),
              ))
          .toList(),
    );
  }
}
