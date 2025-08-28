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
          width: 100,
          height: 100,
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
      return 'assets/tugak/tugak_jump.PNG';
    } else {
      return "assets/tugak/tugak_land.PNG";
    }
  }
}
