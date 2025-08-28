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
    this.width = 110.0,
    this.height = 110.0,
  });

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  static const String _backCard = 'assets/mitutuglung/back_card.PNG';
  static const String _frontCard = 'assets/mitutuglung/front_card.PNG';
  static const String _flipCard = 'assets/mitutuglung/flip_card.PNG';

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
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    _wasRevealed = widget.card.isRevealed || widget.card.isMatched;
    if (_wasRevealed) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isNowRevealed = widget.card.isRevealed || widget.card.isMatched;
    if (isNowRevealed != _wasRevealed) {
      if (isNowRevealed) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
      _wasRevealed = isNowRevealed;
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
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(math.pi * _flipAnimation.value),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: _buildCardContent(_flipAnimation.value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(double value) {
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
                  ? _WordLabel(
                      text: widget.card.content,
                      baseFontSize: (widget.height * 0.16).clamp(10.0, 20.0),
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
        assetPath,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}

class _WordLabel extends StatelessWidget {
  final String text;
  final double baseFontSize;

  const _WordLabel({
    required this.text,
    required this.baseFontSize,
  });

  double _measureWordWidth(String word, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: word,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.size.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxWidth = c.maxWidth;
      final words =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      if (words.isEmpty) {
        return const SizedBox.shrink();
      }

      final longestWord = words.reduce(
        (a, b) => (a.length >= b.length) ? a : b,
      );

      const double minFont = 12.0;
      final double tryFont = baseFontSize;

      //long words might not fit at the base font size
      final wAtBase = _measureWordWidth(longestWord, tryFont);

      //if it doesn't fit, the font is scaled down
      double finalFontSize = tryFont;
      if (wAtBase > maxWidth && wAtBase > 0) {
        final scale = maxWidth / wAtBase;
        finalFontSize = (tryFont * scale).clamp(minFont, tryFont);
      }

      return Center(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: finalFontSize,
              fontWeight: FontWeight.w900,
              color: Colors.brown,
              height: 1.05,
            ),
          ),
        ),
      );
    });
  }
}
