import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionDialog extends StatefulWidget {
  final Question question;
  final Function(int) onAnswer;
  final VoidCallback onTimeout;

  const QuestionDialog({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onTimeout,
  });

  @override
  QuestionDialogState createState() => QuestionDialogState();
}

class QuestionDialogState extends State<QuestionDialog>
    with TickerProviderStateMixin {
  late AnimationController _timerController;

  // 10 seconds to answer
  int timeLeft = 10;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _timerController.forward();
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeout();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 3 / 5,
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xAD572100), width: 10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xAD572100).withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer bar
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  return SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: 1.0 - _timerController.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timerController.value > 0.7
                            ? Colors.red
                            : Colors.green[600]!,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Question
              Text(
                widget.question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),

              // Translation (if exists)
              if (widget.question.englishTrans.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.question.englishTrans,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xAD572100),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 20),

              // Answer choices
              ...widget.question.shuffledChoices.asMap().entries.map((entry) {
                int index = entry.key;
                String choice = entry.value;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAnswer(index);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4BE0A),
                      foregroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      choice,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
