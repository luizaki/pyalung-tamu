import 'package:flutter/material.dart';

import './views/home.dart';
import './views/leaderboard.dart';
import './views/progress.dart';
import './views/settings.dart';

import './services/auth_service.dart';
import './widgets/auth_popup.dart';

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

  Future<void> _handleLogout() async {
    await _authService.logout();
    setState(() {});
    _showAuthPopup();
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
      body: Column(
        children: [
          _buildUserInfoBar(),

          // ✅ Main content area
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
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
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/settings.png',
                  width: 35,
                  height: 35,
                ),
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

  Widget _buildUserInfoBar() {
    final player = _authService.currentPlayer;

    if (player == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            player.isGuest ? Icons.person_outline : Icons.person,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Welcome, ${player.username ?? 'Player'}!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (player.isGuest) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (player.isGuest)
            TextButton(
              onPressed: _showAuthPopup,
              child: const Text(
                'Login to Save Progress',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          else
            TextButton(
              onPressed: _handleLogout,
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
