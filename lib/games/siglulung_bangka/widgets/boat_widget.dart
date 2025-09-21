import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/boat.dart';

class BoatWidget extends StatefulWidget {
  final Boat boat;
  final Size screenSize;
  final int wpm;

  const BoatWidget({
    super.key,
    required this.boat,
    required this.screenSize,
    this.wpm = 0,
  });

  @override
  State<BoatWidget> createState() => _BoatWidgetState();
}

class _BoatWidgetState extends State<BoatWidget> with TickerProviderStateMixin {
  late AnimationController _bobController;
  late AnimationController _tiltController;
  late Animation<double> _bobAnimation;
  late Animation<double> _tiltAnimation;
  late String _boatImage;

  @override
  void initState() {
    super.initState();

    final boats = [
      'assets/siglulung/boat.PNG',
      'assets/siglulung/boat1.PNG',
      'assets/siglulung/boat2.PNG',
      'assets/siglulung/boat3.PNG',
      'assets/siglulung/boat4.PNG',
    ];
    _boatImage = boats[math.Random().nextInt(boats.length)];

    // Bobbing animation (up and down movement)
    _bobController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bobAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bobController,
      curve: Curves.easeInOut,
    ));

    // Tilting animation (side to side movement)
    _tiltController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tiltAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _bobController.repeat(reverse: true);
    _tiltController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BoatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation speed based on boat speed
    _updateAnimationSpeed();
  }

  void _updateAnimationSpeed() {
    final speed = widget.boat.speed;

    // Faster bobbing when boat is faster
    final bobDuration = (1000 - (speed * 80)).clamp(200, 1000).round();
    final tiltDuration = (800 - (speed * 60)).clamp(150, 800).round();

    _bobController.duration = Duration(milliseconds: bobDuration);
    _tiltController.duration = Duration(milliseconds: tiltDuration);
  }

  @override
  void dispose() {
    _bobController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: Offset(
          _getBoatX(),
          _getBoatY(),
        ),
        child: Transform.rotate(
          angle: _getTiltAngle(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                _boatImage,
                width: 150,
                height: 110,
                fit: BoxFit.contain,
                color: widget.boat.isHit
                    ? Colors.red.withValues(alpha: 0.6)
                    : null,
                colorBlendMode:
                    widget.boat.isHit ? BlendMode.modulate : BlendMode.srcIn,
              ),
              if (widget.boat.speed > 3.0) _buildSpeedParticles(),
            ],
          ),
        ),
      ),
    );
  }

  double _getBoatX() {
    final maxWpm = 70;
    final progress = (widget.wpm / maxWpm).clamp(0.0, 1.0);
    final minX = widget.screenSize.width * 0.1;
    final maxX = widget.screenSize.width * 0.85;
    return minX + (maxX - minX) * progress + (_getBobOffset() * 2);
  }

  double _getBoatY() {
    final baseY = widget.screenSize.height * 0.35 + _getBobOffset();
    return baseY;
  }

  double _getBobOffset() {
    // Vertical bobbing based on speed
    final bobIntensity = (widget.boat.speed * 1.5).clamp(1.0, 8.0);
    return math.sin(_bobAnimation.value * 2 * math.pi) * bobIntensity;
  }

  double _getTiltAngle() {
    // Side-to-side tilting based on speed
    final tiltIntensity = (widget.boat.speed * 0.02).clamp(0.01, 0.15);
    return _tiltAnimation.value * tiltIntensity;
  }

  Widget _buildSpeedParticles() {
    return Transform.translate(
      offset: const Offset(-5, 15),
      child: SizedBox(
        width: 20,
        height: 10,
        child: CustomPaint(
          painter: _SpeedParticlesPainter(widget.boat.speed),
        ),
      ),
    );
  }
}

class _SpeedParticlesPainter extends CustomPainter {
  final double speed;

  _SpeedParticlesPainter(this.speed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Draw speed particles
    final particleCount = (speed * 2).clamp(3, 8).round();

    for (int i = 0; i < particleCount; i++) {
      final x = size.width * (i / particleCount);
      final y = size.height * 0.5 + (math.sin(i * 0.5) * 3);

      canvas.drawCircle(
        Offset(x, y),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
