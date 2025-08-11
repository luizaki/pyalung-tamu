import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

class StartScreen extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final String gameTitle;
  final String instructions;
  final Widget gameScreen;

  const StartScreen({
    super.key,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.gameTitle,
    required this.instructions,
    required this.gameScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        // Background
        Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color1,
                color1,
                color2,
                color2,
                color3,
                color3,
                color4,
                color4
              ],
              stops: const [0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0],
            ))),

        // Back button
        Positioned(
            top: 35,
            left: 30,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2BB495),
                  border: Border.all(
                    color: const Color(0xFF443229),
                    width: 2,
                  )),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFF4BE0A),
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )),

        // Main
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Icon
            Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF9DD9A),
                  border: Border.all(color: const Color(0xFFAD5721), width: 10),
                ),
                child: const Icon(
                  Icons.games,
                  size: 100,
                  color: Colors.brown,
                )),

            const SizedBox(height: 20),

            // Title
            StrokeText(
              text: gameTitle,
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF4BE0A),
              ),
              strokeColor: Colors.black,
              strokeWidth: 6,
            ),

            const SizedBox(height: 10),

            // Instructions
            StrokeText(
              text: 'How to Play: $instructions',
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: 24,
                color: Color(0xFFFFFEDE),
              ),
              strokeColor: Colors.black,
              strokeWidth: 4,
            ),

            const SizedBox(height: 20),

            // Play button
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Container(
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xF9DD9A00),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xAD572100),
                    width: 5,
                  ),
                ),
                child: InkWell(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => gameScreen),
                    )
                  },
                  borderRadius: BorderRadius.circular(8),
                  highlightColor: const Color(0xFFCA8505),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Play',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF9DD9A),
                        )),
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    ));
  }
}
