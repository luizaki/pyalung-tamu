import 'package:flutter/material.dart';
import 'dart:math' as math;

class _MovingWavesPainter extends CustomPainter {
  final double boatSpeed;
  final double animationTime;

  _MovingWavesPainter(this.boatSpeed, {this.animationTime = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final waveIntensity = (boatSpeed * 2).clamp(1.0, 10.0);
    final waveSpeed = boatSpeed * 0.1;

    for (int i = 0; i < 8; i++) {
      final y = size.height * 0.15 * (i + 1);
      final path = Path();

      for (double x = 0; x < size.width; x += 12) {
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

    if (boatSpeed > 4.0) _drawSprayEffect(canvas, size, boatSpeed);
  }

  void _drawSprayEffect(Canvas canvas, Size size, double speed) {
    final sprayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < (speed * 3).round(); i++) {
      final x = (size.width * 0.3) + (i * 15.0) % (size.width * 0.4);
      final y = size.height * 0.6 + (math.sin(i * 0.3) * 20);
      canvas.drawCircle(Offset(x, y), 2.0, sprayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Obstacle {
  Offset position;
  double size;
  String imageAsset;
  String? word;
  bool isHit;

  Obstacle({
    required this.position,
    required this.size,
    required this.imageAsset,
    this.word,
    this.isHit = false,
  });
}

class MovingBackground extends StatefulWidget {
  final double boatSpeed;
  final Size screenSize;
  final bool isGameActive;
  final String? currentWord;

  const MovingBackground({
    super.key,
    required this.boatSpeed,
    required this.screenSize,
    required this.isGameActive,
    this.currentWord,
  });

  @override
  State<MovingBackground> createState() => _MovingBackgroundState();
}

class _MovingBackgroundState extends State<MovingBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> obstacleImages = [
    'assets/siglulung/obs1.PNG',
    'assets/siglulung/obs2.PNG',
  ];

  final List<Obstacle> obstacles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        _updateObstacles();
      });

    _animation = Tween<double>(begin: 0.0, end: 2 * math.pi)
        .animate(_animationController);

    if (widget.isGameActive) {
      _animationController.repeat();
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    if (!widget.isGameActive) return;

    final size = 25 + _random.nextDouble() * 20;
    final y = _random.nextDouble() * (widget.screenSize.height * 0.6);

    obstacles.add(
      Obstacle(
        position: Offset(widget.screenSize.width + size, y),
        size: size,
        imageAsset: obstacleImages[_random.nextInt(obstacleImages.length)],
        word: widget.currentWord ?? 'default',
      ),
    );

    Future.delayed(const Duration(seconds: 2), _spawnObstacle);
  }

  void _updateObstacles() {
    setState(() {
      for (var obs in obstacles) {
        if (!obs.isHit) {
          obs.position = Offset(
            obs.position.dx - widget.boatSpeed * 0.3,
            obs.position.dy,
          );
          if (obs.position.dx + obs.size < 0) obs.isHit = true;
        }
      }

      if (widget.currentWord != null) {
        for (var obs in obstacles) {
          if (obs.word == widget.currentWord) obs.isHit = true;
        }
      }
    });
  }

  @override
  void didUpdateWidget(MovingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGameActive != oldWidget.isGameActive) {
      if (widget.isGameActive) {
        _animationController.repeat();
        _spawnObstacle();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
              CustomPaint(
                size: Size.infinite,
                painter: _MovingWavesPainter(
                  widget.boatSpeed,
                  animationTime: _animation.value,
                ),
              ),
              Stack(
                children: _buildObstaclesStack(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildObstaclesStack() {
    return obstacles
        .where((o) => !o.isHit)
        .map(
          (o) => Transform.translate(
            offset: o.position,
            child: Image.asset(
              o.imageAsset,
              width: o.size,
              height: o.size,
              fit: BoxFit.contain,
            ),
          ),
        )
        .toList();
  }
}
