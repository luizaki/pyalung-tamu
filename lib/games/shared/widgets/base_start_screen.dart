import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

const Size _screenSize = Size(1280, 720);

class StartScreen extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final String gameTitle;
  final String instructions;
  final Widget gameScreen;

  final String? backgroundImage;
  final String? gameIcon;

  const StartScreen({
    super.key,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.gameTitle,
    required this.instructions,
    required this.gameScreen,
    this.backgroundImage,
    this.gameIcon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleW = size.width / _screenSize.width;
    final scaleH = size.height / _screenSize.height;
    final scale = (scaleW + scaleH) / 2;

    final circleDim = 200.0 * scale;
    final circleBorder = 10.0 * scale;
    final backBtnSize = 55.0 * scale;
    final backBtnBorder = 2.0 * scale;
    final backIconSize = 30.0 * scale;
    final backTop = 35.0 * scale;
    final backLeft = 30.0 * scale;

    final titleSize = 64.0 * scale;
    final titleStroke = 6.0 * scale;
    final instrSize = 32.0 * scale;
    final instrStroke = 4.0 * scale;

    final outerBorder = 5.0 * scale;
    final cardRadius = 16.0 * scale;
    final innerRadius = 8.0 * scale;
    final cardMargin = 32.0 * scale;
    final playPadding = 12.0 * scale;
    final playFont = 24.0 * scale;

    final playWidth = (320.0 * scale).clamp(180.0, size.width * 0.6);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: backgroundImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  )
                : BoxDecoration(
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
                    ),
                  ),
          ),

          // Back button
          Positioned(
            top: backTop,
            left: backLeft,
            child: Container(
              width: backBtnSize,
              height: backBtnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2BB495),
                border: Border.all(
                  color: const Color(0xFF443229),
                  width: backBtnBorder,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFFF4BE0A),
                  size: backIconSize,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Main
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  width: circleDim,
                  height: circleDim,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF9DD9A),
                    border: Border.all(
                      color: const Color(0xFFAD5721),
                      width: circleBorder,
                    ),
                  ),
                  child: gameIcon != null
                      ? ClipOval(
                          child: Image.asset(
                            gameIcon!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.games,
                          size: 100 * scale,
                          color: Colors.brown,
                        ),
                ),

                SizedBox(height: 20 * scale),

                // Title
                StrokeText(
                  text: gameTitle,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF4BE0A),
                  ),
                  strokeColor: Colors.black,
                  strokeWidth: titleStroke,
                ),

                SizedBox(height: 10 * scale),

                // Instructions
                StrokeText(
                  text: 'How to Play: $instructions',
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: instrSize,
                    color: const Color(0xFFFFFEDE),
                  ),
                  strokeColor: Colors.black,
                  strokeWidth: instrStroke,
                ),

                SizedBox(height: 20 * scale),

                // Play button
                SizedBox(
                  width: playWidth,
                  child: Container(
                    margin: EdgeInsets.all(cardMargin),
                    decoration: BoxDecoration(
                      color: const Color(0xF9DD9A00),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(
                        color: const Color(0xAD572100),
                        width: outerBorder,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => gameScreen),
                        );
                      },
                      borderRadius: BorderRadius.circular(innerRadius),
                      highlightColor: const Color(0xFFCA8505),
                      child: Padding(
                        padding: EdgeInsets.all(playPadding),
                        child: Text(
                          'Play',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: playFont,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF9DD9A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
