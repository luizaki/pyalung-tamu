import 'package:flutter/material.dart';
import 'dart:math' as math;

class _MovingWavesPainter extends CustomPainter {
  final double boatSpeed;
  final double animationTime;

  _MovingWavesPainter(this.boatSpeed, {this.animationTime = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Wave intensity and movement based on boat speed
    final waveIntensity = (boatSpeed * 2).clamp(1.0, 10.0);
    final waveSpeed = boatSpeed * 0.1;

    // Draw multiple wave lines that move faster with higher speed
    for (int i = 0; i < 8; i++) {
      final y = size.height * 0.15 * (i + 1);
      final path = Path();

      for (double x = 0; x < size.width; x += 12) {
        // More pronounced wave movement
        final offset = (x * 0.03 + animationTime * waveSpeed) % (2 * math.pi);
        final waveY = y + (waveIntensity * math.sin(offset));

        if (x == 0) {
          path.moveTo(x, waveY);
        } else {
          path.lineTo(x, waveY);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Add foam/spray effects when going fast
    if (boatSpeed > 4.0) {
      _drawSprayEffect(canvas, size, boatSpeed);
    }
  }

  void _drawSprayEffect(Canvas canvas, Size size, double speed) {
    final sprayPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw spray particles across the screen
    for (int i = 0; i < (speed * 3).round(); i++) {
      final x = (size.width * 0.3) + (i * 15.0) % (size.width * 0.4);
      final y = size.height * 0.6 + (math.sin(i * 0.3) * 20);

      canvas.drawCircle(
        Offset(x, y),
        2.0,
        sprayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MovingBackground extends StatefulWidget {
  final double boatSpeed;
  final Size screenSize;

  const MovingBackground({
    super.key,
    required this.boatSpeed,
    required this.screenSize,
  });

  @override
  State<MovingBackground> createState() => _MovingBackgroundState();
}

class _MovingBackgroundState extends State<MovingBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF4682B4),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Moving water waves with animation time
                CustomPaint(
                  size: Size.infinite,
                  painter: _MovingWavesPainter(
                    widget.boatSpeed,
                    animationTime: _animation.value,
                  ),
                ),

                // Moving islands
                _buildMovingIslands(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMovingIslands() {
    // Move islands based on boat speed
    final islandOffset = _animation.value * widget.boatSpeed * 10;

    return Stack(
      children: [
        _buildMovingIsland(widget.screenSize.width * 0.2 - islandOffset,
            widget.screenSize.height * 0.3, 25),
        _buildMovingIsland(widget.screenSize.width * 0.7 - islandOffset,
            widget.screenSize.height * 0.4, 30),
        _buildMovingIsland(widget.screenSize.width * 0.4 - islandOffset,
            widget.screenSize.height * 0.2, 20),
        _buildMovingIsland(widget.screenSize.width * 0.8 - islandOffset,
            widget.screenSize.height * 0.6, 35),
      ],
    );
  }

  Widget _buildMovingIsland(double x, double y, double size) {
    return Positioned(
      left: x % (widget.screenSize.width + 100) - 50, // Wrap around screen
      top: y,
      child: Container(
        width: size,
        height: size * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          color: Colors.green[700],
          border: Border.all(
            color: Colors.green[800]!,
            width: 1,
          ),
        ),
      ),
    );
  }
}
