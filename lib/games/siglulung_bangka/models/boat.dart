class Boat {
  double position;
  double speed;
  bool isHit;
  DateTime? lastHitTime;

  static const double maxSpeed = 10.0;
  static const double minSpeed = 0.5;
  static const double hitSlowdown = 0.3;
  static const int hitRecovery = 1000;

  Boat({
    this.position = 0.0,
    this.speed = 1.0,
    this.isHit = false,
  });

  void updateSpeed(double wpm) {
    double targetSpeed = minSpeed + (wpm / 100.0) * (maxSpeed - minSpeed);
    targetSpeed = targetSpeed.clamp(minSpeed, maxSpeed);

    if (isHit) {
      final timeSinceLastHit = DateTime.now()
          .difference(lastHitTime ?? DateTime.now())
          .inMilliseconds;

      if (timeSinceLastHit < hitRecovery) {
        targetSpeed *= hitSlowdown;
      } else {
        isHit = false;
        lastHitTime = null;
      }
    }

    speed = targetSpeed;
  }

  void hit() {
    isHit = true;
    lastHitTime = DateTime.now();
  }

  void move(double delta) {
    position += (speed * delta) / 1000.0;
    position = position.clamp(0.0, 1.0);
  }

  bool get hasFinished => position >= 1.0;
}
