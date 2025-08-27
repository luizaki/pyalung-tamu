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

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..forward();

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeout();
        if (mounted) Navigator.of(context).pop();
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
    final size = MediaQuery.of(context).size;
    final maxW = (size.width * 0.90).clamp(300.0, 680.0);
    final maxH = size.height * 0.80;

    final choices = widget.question.shuffledChoices;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xF9DD9A00),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xAD572100), width: 10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xAD572100).withOpacity(0.2),
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
                    builder: (_, __) => SizedBox(
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
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Question text
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 12.0;
                        final n = choices.length;
                        final totalGaps = gap * (n - 1);
                        final perButtonH =
                            ((constraints.maxHeight - totalGaps) / n)
                                .clamp(44.0, 72.0);

                        return Column(
                          children: List.generate(n, (i) {
                            final choice = choices[i];
                            return SizedBox(
                              height: perButtonH,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  widget.onAnswer(i);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF4BE0A),
                                  foregroundColor: Colors.brown,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      choice,
                                      style: const TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ).withGapBelow(i < n - 1 ? gap : 0);
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _Gap on Widget {
  Widget withGapBelow(double gap) => gap > 0
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [this, SizedBox(height: gap)])
      : this;
}
