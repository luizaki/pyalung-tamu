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
    this.width = 100.0,
    this.height = 100.0,
  });

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  //sprites
  static const String _backCard = 'assets/mitutuglung/back_card.png';
  static const String _frontCard = 'assets/mitutuglung/front_card.png';
  static const String _flipCard = 'assets/mitutuglung/flip_card.png';

  // Handle flip anim
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool _wasRevealed = false;

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

    _wasRevealed = widget.card.isRevealed || widget.card.isMatched;
    if (_wasRevealed) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isCurrentlyRevealed = widget.card.isRevealed || widget.card.isMatched;

    if (isCurrentlyRevealed != _wasRevealed) {
      if (isCurrentlyRevealed) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
      _wasRevealed = isCurrentlyRevealed;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, _) {
          final v = _flipAnimation.value;
          
          return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(math.pi * _flipAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: const EdgeInsets.all(4),
                child: _buildCardContent(v),
              ));
        },
      ),
    );
  }

  Widget _buildCardContent(double value) {
    // build card depending on face
    if (value > 0.40 && value < 0.60) {
      return _buildSprite(_flipCard);
    }
    if (value <= 0.50) {
      return _buildSprite(_frontCard);
    }
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildSprite(_backCard),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: widget.card.isWord
            ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
              widget.card.content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 200,
                fontWeight: FontWeight.w900,
                color: Colors.brown,
              ),
            ),
          )
          : FittedBox(
            fit: BoxFit.contain,
            child: Image.network(
            widget.card.content,
            filterQuality: FilterQuality.none,
          ),
          ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSprite(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        assetPath, fit: BoxFit.fill, filterQuality: FilterQuality.none,
      ),
    );
    
  }
}