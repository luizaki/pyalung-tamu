import 'package:flutter/material.dart';

class Lilypad extends StatelessWidget {
  final double x;
  final double y;

  final bool hasRipple;

  const Lilypad({
    super.key,
    required this.x,
    required this.y,
    this.hasRipple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        child: Image.asset(
          _getLilypadAsset(),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
  String _getLilypadAsset() {
    if (hasRipple) {
      return 'assets/tugak/lily1.png';
    } else {
      return 'assets/tugak/lily2.png';
    }
  }
}