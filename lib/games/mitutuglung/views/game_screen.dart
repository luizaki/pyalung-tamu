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
      _buildCardsGrid(),
    ];
  }

  Widget _buildCardsGrid() {
    final cardsGrid = controller.getCardsGrid();

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cardsGrid.map((row) => _buildCardRow(row)).toList(),
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
