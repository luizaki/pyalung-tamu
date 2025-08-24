import 'package:flutter/material.dart';
import '../models/word.dart';

class WordQueueDisplay extends StatelessWidget {
  final TypedWord? currentWord;
  final List<String> upcomingWords;
  final double screenWidth;

  const WordQueueDisplay({
    super.key,
    required this.currentWord,
    required this.upcomingWords,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Current word being typed
            if (currentWord != null) _buildCurrentWord(),

            // Separator
            if (currentWord != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '|',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Upcoming words
            ..._buildUpcomingWords(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWord() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        children: _buildCurrentWordSpans(),
      ),
    );
  }

  List<Widget> _buildUpcomingWords() {
    final wordsList = upcomingWords.take(5).toList();

    return wordsList.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;

      return Container(
        margin: const EdgeInsets.only(right: 20),
        child: Text(
          word,
          style: TextStyle(
            fontSize:
                index == 0 ? 24 : 20, // First upcoming word slightly larger
            color: index == 0 ? Colors.grey[700] : Colors.grey[500],
            fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
    }).toList();
  }

  List<TextSpan> _buildCurrentWordSpans() {
    final word = currentWord!;
    final spans = <TextSpan>[];

    // Typed characters
    for (int i = 0; i < word.typedText.length; i++) {
      final typedChar = word.typedText[i];
      final actualChar = i < word.word.length ? word.word[i] : '';
      final isCorrect = typedChar == actualChar;

      spans.add(TextSpan(
        text: typedChar,
        style: TextStyle(
          color: isCorrect ? Colors.green[700] : Colors.red[700],
          backgroundColor: isCorrect
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
        ),
      ));
    }

    // Remaining characters with cursor
    final remaining = word.remainingText;
    for (int i = 0; i < remaining.length; i++) {
      final isNext = i == 0;

      spans.add(TextSpan(
        text: remaining[i],
        style: TextStyle(
          color: isNext ? Colors.blue[800] : Colors.grey[700],
          backgroundColor: isNext ? Colors.blue.withOpacity(0.1) : null,
          decoration: isNext ? TextDecoration.underline : null,
          decorationColor: Colors.blue[800],
          decorationThickness: 3,
        ),
      ));
    }

    return spans;
  }
}
