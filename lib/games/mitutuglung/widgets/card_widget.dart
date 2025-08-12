import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/card.dart';

class CardWidget extends StatefulWidget {
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
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  // Handle flip anim
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Handle color transition
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  bool _wasRevealed = false;
  bool _wasMatched = false;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xF9DD9A00),
      end: const Color(0xFFBA750D),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _wasRevealed = widget.card.isRevealed || widget.card.isMatched;
    _wasMatched = widget.card.isMatched;

    if (_wasRevealed) {
      _flipController.value = 1.0;
    }

    if (_wasMatched) {
      _colorController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isCurrentlyRevealed = widget.card.isRevealed || widget.card.isMatched;
    final isCurrentlyMatched = widget.card.isMatched;

    if (isCurrentlyRevealed != _wasRevealed) {
      if (isCurrentlyRevealed) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
      _wasRevealed = isCurrentlyRevealed;
    }

    if (isCurrentlyMatched != _wasMatched) {
      if (isCurrentlyMatched) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
      _wasMatched = isCurrentlyMatched;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(math.pi * _flipAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getCardColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xAD572100),
                    width: 3,
                  ),
                ),
                child: _buildCardContent(),
              ));
        },
      ),
    );
  }

  Color _getCardColor() {
    if (widget.card.isMatched) {
      return _colorAnimation.value ?? const Color(0xFFBA750D);
    }

    if (_flipAnimation.value <= 0.5) {
      return const Color(0xFF2BB495);
    } else {
      return const Color(0xF9DD9A00);
    }
  }

  Widget _buildCardContent() {
    // build card depending on face
    if (_flipAnimation.value <= 0.5) {
      return _buildCardBack();
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: _buildCardFront(),
    );
  }

  Widget _buildCardBack() {
    return const Center(
      child: Icon(
        Icons.help_outline,
        size: 40,
        color: Colors.brown,
      ),
    );
  }

  Widget _buildCardFront() {
    if (widget.card.isWord) {
      return Center(
        child: Text(widget.card.content,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            textAlign: TextAlign.center),
      );
    } else {
      return Center(
        child: Image.network(
          widget.card.content,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      );
    }
  }
}
