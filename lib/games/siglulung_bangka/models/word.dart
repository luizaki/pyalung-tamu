class TypedWord {
  final String word;
  String typedText;
  bool isCompleted;
  bool hasError;

  TypedWord({
    required this.word,
    this.typedText = '',
    this.isCompleted = false,
    this.hasError = false,
  });

  double get progress => word.isEmpty ? 0.0 : typedText.length / word.length;

  bool get isCorrect {
    if (typedText.isEmpty) return true;
    if (typedText.length > word.length) return false;
    return typedText == word.substring(0, typedText.length);
  }

  String get remainingText {
    if (typedText.length >= word.length) return '';
    return word.substring(typedText.length);
  }

  void addCharacter(String character) {
    if (!isCompleted) {
      typedText += character;
      hasError = !isCorrect;

      if (typedText.length == word.length && isCorrect) {
        isCompleted = true;
      }
    }
  }

  void removeCharacter() {
    if (typedText.isNotEmpty) {
      typedText = typedText.substring(0, typedText.length - 1);
      hasError = !isCorrect;
      isCompleted = false;
    }
  }

  void reset() {
    typedText = '';
    isCompleted = false;
    hasError = false;
  }
}
