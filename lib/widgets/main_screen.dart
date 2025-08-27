import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> children;
  final String? background;

  const MainScreen({super.key, required this.children, this.background});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //default
        Positioned.fill(
          child: Image.asset(
            background ?? 'assets/bg/bg_simple.png',
            fit: BoxFit.cover,
          ),
        ),

        Container(
          padding: const EdgeInsets.only(bottom: 80),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 3 / 5,
              child: Container(
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xF9DD9A00),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xAD572100),
                    width: 10,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xAD572100).withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
