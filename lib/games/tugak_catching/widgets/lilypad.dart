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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: hasRipple ? Colors.lightBlue[300] : Colors.green[400],
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: hasRipple ? Colors.blue[600]! : Colors.green[700]!,
            width: 3,
          ),
        ),
        child: Icon(
          Icons.local_florist,
          size: 30,
          color: hasRipple ? Colors.blue[800] : Colors.green[800],
        ),
      ),
    );
  }
}
