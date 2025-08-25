import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/boat.dart';

class BoatWidget extends StatefulWidget {
  final Boat boat;
  final Size screenSize;

  const BoatWidget({
    super.key,
    required this.boat,
    required this.screenSize,
  });

  @override
  State<BoatWidget> createState() => _BoatWidgetState();
}

class _BoatWidgetState extends State<BoatWidget> with TickerProviderStateMixin {
  late AnimationController _bobController;
  late AnimationController _tiltController;
  late Animation<double> _bobAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();

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
    return Positioned(
      // Fixed horizontal position, but add slight movement
      left: widget.screenSize.width * 0.4 + (_getBobOffset() * 2),
      top: widget.screenSize.height * 0.55 + _getBobOffset(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_bobAnimation, _tiltAnimation]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _getTiltAngle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: widget.boat.isHit ? Colors.red[400] : Colors.blue[600],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      widget.boat.isHit ? Colors.red[700]! : Colors.blue[800]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius:
                        4 + (widget.boat.speed * 0.5), // More blur when faster
                    offset: Offset(2, 2 + _getBobOffset() * 0.5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'BOAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Speed indicator particles when going fast
                  if (widget.boat.speed > 3.0) _buildSpeedParticles(),
                ],
              ),
            ),
          );
        },
      ),
    );
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
    return Positioned(
      right: -5,
      top: 15,
      child: Container(
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
      ..color = Colors.white.withOpacity(0.8)
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
