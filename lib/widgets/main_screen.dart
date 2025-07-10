import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> children;

  MainScreen({required this.children});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //bg_simple
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg/bg_simple.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Center(
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
                        color: const Color(0xAD572100).withOpacity(0.2),
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
                      )))),
        ),
      ],
    );
  }
}
