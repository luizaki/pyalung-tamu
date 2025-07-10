import 'package:flutter/material.dart';

import './views/home.dart';
import './views/leaderboard.dart';
import './views/progress.dart';
import './views/settings.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LeaderboardPage(),
    ProgressPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/button_boxes/navbar.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: [
              BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/home.png',
                    width: 35,
                    height: 35,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/leaderboard.png',
                  width: 35,
                  height: 35,
                ),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/progress.png',
                  width: 35,
                  height: 35,
                ),
                label: 'Progress',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 35),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
