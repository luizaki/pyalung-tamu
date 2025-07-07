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
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(32),
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
      ],
    );
  }
}
