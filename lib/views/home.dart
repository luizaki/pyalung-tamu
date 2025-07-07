import 'package:flutter/material.dart';

import './leaderboard.dart';
import './progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Screen area
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[100],
            child: Center(
              // Box area (title and game selector)
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 3 / 5,
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Pyalung Tamu',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Siglulung Bangka
                        Card(
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[100],
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(children: [
                              Icon(
                                Icons.directions_boat,
                                size: 32,
                                color: Colors.brown,
                              ),
                              Expanded(
                                child: Text('Siglulung Bangka',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ),
                            ]),
                          ),
                        ),

                        // Tugak Catching
                        Card(
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[100],
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(children: [
                              Icon(
                                Icons.gamepad,
                                size: 32,
                                color: Colors.brown,
                              ),
                              Expanded(
                                child: Text('Tugak Catching',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ),
                            ]),
                          ),
                        ),

                        // Mitutuglung
                        Card(
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[100],
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(children: [
                              Icon(
                                Icons.card_membership,
                                size: 32,
                                color: Colors.brown,
                              ),
                              Expanded(
                                child: Text('Mitutuglung',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
