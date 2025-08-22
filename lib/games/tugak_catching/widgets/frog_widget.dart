import 'package:flutter/material.dart';
import '../models/frog.dart';

class FrogWidget extends StatelessWidget {
  final Frog frog;
  final VoidCallback onTap;

  const FrogWidget({
    super.key,
    required this.frog,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: frog.x,
      top: frog.y,
      child: GestureDetector(
        onTap: frog.isJumping ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          child: Image.asset(
            _getFrogAsset(),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }

  String _getFrogAsset() {
    if (frog.isJumping) {
      return 'assets/tugak/frog_jump_500.png';
    } else {
      return 'assets/tugak/frog_land_500.png';
    }
  }
  
}
