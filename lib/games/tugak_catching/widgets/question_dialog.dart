import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionDialog extends StatefulWidget {
  final Question question;
  final int timeoutSeconds;
  final Function(int) onAnswer;
  final VoidCallback onTimeout;

  const QuestionDialog({
    super.key,
    required this.question,
    required this.timeoutSeconds,
    required this.onAnswer,
    required this.onTimeout,
  });

  @override
  QuestionDialogState createState() => QuestionDialogState();
}

class QuestionDialogState extends State<QuestionDialog>
    with TickerProviderStateMixin {
  late AnimationController _timerController;

  int? _selectedIndex;
  bool? _selectedCorrect;
  bool _locked = false;

  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;
    _timerController = AnimationController(
      duration: Duration(seconds: _remainingSeconds),
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

  void _handleTap(int i, String choice) {
    if (_locked) return;
    final bool isCorrect = choice == widget.question.correctAnswer;
    setState(() {
      _selectedIndex = i;
      _selectedCorrect = isCorrect;
      _locked = true;
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      widget.onAnswer(i);
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;

    final double maxH = (size.height * 0.70).clamp(360.0, 560.0);
    final double maxW = math.min(size.width * 0.96, maxH * 1.35);

    final choices = widget.question.shuffledChoices;
    final engChoices = widget.question.shuffledEngChoices;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: Container(
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
                  const SizedBox(height: 16),

                  //Question
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: (maxH * 0.22).clamp(60.0, 150.0)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        widget.question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
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

                  const SizedBox(height: 16),

                  //Answer choices
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        const gap = 12.0;
                        final n = choices.length;
                        const double minH = 44.0;
                        const double maxBtnH = 68.0;

                        final totalGap = gap * (n - 1);
                        final rawPer = (c.maxHeight - totalGap) / n;
                        final perButtonH =
                            rawPer.clamp(minH, maxBtnH).floorToDouble();

                        final need = n * perButtonH + totalGap;
                        final canFit = need <= c.maxHeight + 0.5;

                        Widget buildList(ScrollPhysics physics) {
                          return ListView.separated(
                            physics: physics,
                            padding: EdgeInsets.zero,
                            itemCount: n,
                            itemBuilder: (context, i) {
                              final choice = choices[i];
                              final engChoice = engChoices[i];

                              final bool isSelected = _selectedIndex == i;
                              final bool showResult =
                                  isSelected && _selectedCorrect != null;
                              final Color resultColor =
                                  (_selectedCorrect ?? false)
                                      ? Colors.green.shade700
                                      : Colors.red.shade600;

                              final BorderSide side = showResult
                                  ? BorderSide(color: resultColor, width: 3)
                                  : const BorderSide(
                                      color: Colors.transparent, width: 2);

                              final Color textColor =
                                  showResult ? resultColor : Colors.brown;

                              return SizedBox(
                                height: perButtonH,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _locked
                                      ? null
                                      : () => _handleTap(i, choice),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF4BE0A),
                                    foregroundColor: textColor,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      side: side,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$choice ($engChoice)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: gap),
                          );
                        }

                        return canFit
                            ? buildList(const NeverScrollableScrollPhysics())
                            : buildList(const ClampingScrollPhysics());
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
