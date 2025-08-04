import 'package:flutter/material.dart';
import '../models/frog.dart';

class FrogWidget extends StatelessWidget {
  final Frog frog;
  final VoidCallback onTap;

  const FrogWidget({
    super.key,
    required this.frog,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: frog.x,
      top: frog.y,
      child: GestureDetector(
        onTap: frog.isJumping ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: frog.isAnswered ? Colors.green[800] : Colors.green[600],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.green[900] ?? Colors.green,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.adb,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
