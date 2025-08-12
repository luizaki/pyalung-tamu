import 'package:flutter/material.dart';
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final MitutuglungCard card;
  final VoidCallback onTap;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.width = 75.0,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: 3,
          ),
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Color _getCardColor() {
    if (card.isHidden) {
      return const Color(0xFF2BB495);
    } else if (card.isMatched) {
      return const Color(0xFF965D08);
    } else {
      return const Color(0xF9DD9A00);
    }
  }

  Color _getBorderColor() {
    return const Color(0xAD572100);
  }

  Widget _buildCardContent() {
    if (card.isHidden) {
      return const Center(
        child: Icon(
          Icons.help_outline,
          size: 40,
          color: Colors.brown,
        ),
      );
    }

    if (card.isWord) {
      return Center(
        child: Text(card.content,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            textAlign: TextAlign.center),
      );
    } else {
      return Center(
        child: Image.network(
          card.content,
          fit: BoxFit.cover,
          width: 30,
          height: 30,
        ),
      );
    }
  }
}
