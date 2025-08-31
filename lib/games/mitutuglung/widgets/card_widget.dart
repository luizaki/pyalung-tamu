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
    final dpr = MediaQuery.of(context).devicePixelRatio;
    double snapDown(double v) => (v * dpr - 0.5).floor() / dpr;

    final w = snapDown(widget.width);
    final h = snapDown(widget.height);

    final edge = math.min(w, h);
    final innerPad = (edge * 0.3).clamp(18.0, 30.0);

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
              width: w,
              height: h,
              child: _buildCardContent(_flipAnimation.value, innerPad),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(double value, double innerPad) {
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
              padding: EdgeInsets.all(innerPad),
              child: widget.card.isWord
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Kapampangan word
                        _WordLabel(
                          text: widget.card.content,
                          baseFontSize:
                              (widget.height * 0.145).clamp(11.0, 18.0),
                        ),

                        // English trans
                        if (widget.card.englishTrans.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _WordLabel(
                            text: '(${widget.card.englishTrans})',
                            baseFontSize:
                                (widget.height * 0.11).clamp(9.0, 14.0),
                          ),
                        ],
                      ],
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

  double _measureWidth(String text, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.size.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final maxWidth = cons.maxWidth;
      const double minFont = 12.0;

      double finalFontSize = baseFontSize;

      final words =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isNotEmpty) {
        final longestWord = words.reduce(
          (a, b) => (a.length >= b.length) ? a : b,
        );

        final wLongest = _measureWidth(longestWord, baseFontSize);
        if (wLongest > maxWidth) {
          final scale = maxWidth / wLongest;
          finalFontSize = (baseFontSize * scale).clamp(minFont, baseFontSize);
        }
      }

      final totalWidth = _measureWidth(text, finalFontSize);
      if (totalWidth > maxWidth) {
        final scale = maxWidth / totalWidth;
        finalFontSize = (finalFontSize * scale).clamp(minFont, finalFontSize);
      }

      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: finalFontSize,
              fontWeight: FontWeight.w900,
              color: Colors.brown,
              height: 1.1,
            ),
          ),
        ),
      );
    });
  }
}
