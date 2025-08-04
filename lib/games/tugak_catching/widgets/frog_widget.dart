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
            color: _getFrogColor(),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _getFrogBorderColor(),
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

  Color _getFrogColor() {
    switch (frog.answerResult) {
      case AnswerResult.correct:
        return Colors.green[800]!;
      case AnswerResult.incorrect:
        return Colors.brown[600]!;
      case AnswerResult.timeout:
        return Colors.grey[700]!;
      case AnswerResult.none:
      default:
        return Colors.green[600]!;
    }
  }

  Color _getFrogBorderColor() {
    switch (frog.answerResult) {
      case AnswerResult.correct:
        return Colors.green[900]!;
      case AnswerResult.incorrect:
        return Colors.brown[700]!;
      case AnswerResult.timeout:
        return Colors.grey[800]!;
      case AnswerResult.none:
      default:
        return Colors.green[700]!;
    }
  }
}
