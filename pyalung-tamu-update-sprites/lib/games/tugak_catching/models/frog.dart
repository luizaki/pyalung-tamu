import './question.dart';

enum AnswerResult { none, correct, incorrect, timeout }

class Frog {
  // frog position
  double x;
  double y;

  // target position for the frog to jump to
  double targetX;
  double targetY;

  // frog state
  bool isJumping;
  bool isBeingQuestioned;
  bool isAnswered;

  // assigned question
  Question question;
  AnswerResult answerResult;

  Frog(
      {required this.x,
      required this.y,
      required this.question,
      this.targetX = 0.0,
      this.targetY = 0.0,
      this.isJumping = false,
      this.isBeingQuestioned = false,
      this.isAnswered = false,
      this.answerResult = AnswerResult.none});

  void jumpTo(double newX, double newY) {
    targetX = newX;
    targetY = newY;
    isJumping = true;
  }

  void updatePosition(double progress) {
    if (isJumping && progress <= 1.0) {
      x = x + (targetX - x) * progress;
      y = y + (targetY - y) * progress;

      if (progress >= 1.0) {
        x = targetX;
        y = targetY;
        isJumping = false;
      }
    }
  }
}
