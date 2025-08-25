import 'package:flutter/material.dart';

import './services/auth_service.dart';

import './views/home.dart';
import './views/leaderboard.dart';
import 'views/progress/progress.dart';
import './views/settings.dart';

import './widgets/auth_popup.dart';
import './widgets/user_menu.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  bool _isInitialized = false;

  final List<Widget> _pages = const [
    HomePage(),
    LeaderboardPage(),
    ProgressPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize();

    setState(() => _isInitialized = true);

    // Show auth popup if user is not logged in
    if (_authService.currentPlayer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthPopup();
      });
    }
  }

  Future<void> _showAuthPopup() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AuthPopup(),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _onUserStateChanged() {
    setState(() {});

    // If no player after state change, show auth popup
    if (_authService.currentPlayer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthPopup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final player = _authService.currentPlayer;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/button_boxes/navbar.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
        ),

// Nav items
        Positioned(
          left: 16,
          right: 16,
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, 'assets/icons/home.png', 'Home'),
              _buildNavItem(1, 'assets/icons/leaderboard.png', 'Leaderboard'),
              _buildNavItem(2, 'assets/icons/progress.png', 'Progress'),
              _buildNavItem(3, 'assets/icons/settings.png', 'Settings'),
            ],
          ),
        ),

// Profile
        if (player != null)
          Positioned(
            left: 18,
            bottom: 12,
            child: Row(
              children: [
                UserMenu(
                  player: player,
                  onUpdate: _onUserStateChanged,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.username ?? 'Player',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xF9DD9A00),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        player.isGuest
                            ? 'Guest'
                            : 'Score: ${player.totalScore ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
