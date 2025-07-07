import 'package:flutter/material.dart';
import './leaderboard.dart';
import './progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSettingsPanelOpen = false;

  void _toggleSettingsPanel() {
    setState(() {
      _isSettingsPanelOpen = !_isSettingsPanelOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                    children: [
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
                            Icon(Icons.directions_boat, size: 32, color: Colors.brown),
                            Expanded(
                              child: Text('Siglulung Bangka',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16)),
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
                            Icon(Icons.gamepad, size: 32, color: Colors.brown),
                            Expanded(
                              child: Text('Tugak Catching',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16)),
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
                            Icon(Icons.card_membership, size: 32, color: Colors.brown),
                            Expanded(
                              child: Text('Mitutuglung',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16)),
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

          // Settings icon
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _toggleSettingsPanel,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.settings, size: 24, color: Colors.grey[700]),
              ),
            ),
          ),

          // Overlay
          if (_isSettingsPanelOpen)
            GestureDetector(
              onTap: _toggleSettingsPanel,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.3),
              ),
            ),

          // Settings panel
          if (_isSettingsPanelOpen)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 3 / 5,
                margin: const EdgeInsets.all(32),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Settings',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(Icons.volume_up, color: Colors.brown),
                                  title: const Text('Sound Effects'),
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (newValue) {},
                                  ),
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(Icons.music_note, color: Colors.brown),
                                  title: const Text('Background Music'),
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (newValue) {},
                                  ),
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.white,
                                child: ListTile(
                                  leading: const Icon(Icons.language, color: Colors.brown),
                                  title: const Text('Language'),
                                  trailing: DropdownButton<String>(
                                    value: 'English',
                                    items: const [
                                      DropdownMenuItem(value: 'English', child: Text('English')),
                                      DropdownMenuItem(value: 'Filipino', child: Text('Filipino')),
                                    ],
                                    onChanged: (newValue) {},
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _toggleSettingsPanel,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child:
                                  Icon(Icons.close, size: 24, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            'assets/button_boxes/navbar.png',
            width: double.infinity,
            height: 70,
            fit: BoxFit.cover,
          ),

          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: [
              BottomNavigationBarItem(icon: Image.asset('assets/icons/home.png', width: 35, height: 35,), label: 'Home',),
              BottomNavigationBarItem(icon: Image.asset('assets/icons/leaderboard.png', width: 35, height: 35,), label: 'Leaderboard',),
              BottomNavigationBarItem(icon: Image.asset('assets/icons/progress.png', width: 35, height: 35,), label: 'Progress',),
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgressPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}