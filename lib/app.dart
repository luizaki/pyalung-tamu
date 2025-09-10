import 'package:flutter/material.dart';

import './services/auth_service.dart';
import './services/game_service.dart';

import './views/home.dart';
import './views/leaderboard.dart';
import 'views/progress.dart';
import './views/settings.dart';

import './widgets/auth_popup.dart';
import './widgets/user_menu.dart';
import './audio/audio_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final AuthService _authService = AuthService();
  final GameService _gameService = GameService();

  bool _isInitialized = false;

  late final AudioController _audioController;

  @override
  void initState() {
    super.initState();

    _audioController = AudioController();
    _audioController.init(enabled: true);

    _initializeAuth();
  }

  @override
  void dispose() {
    //end bgm when app is closed
    // _audioController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize();
    setState(() => _isInitialized = true);

    // Show auth popup if user is not logged in
    if (_authService.currentPlayer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _authService.currentPlayer == null) {
          _showAuthPopup();
        }
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

  void _onUserStateChanged() async {
    setState(() {});

    if (_authService.currentPlayer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _authService.currentPlayer == null) {
          _showAuthPopup();
        }
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

    final pages = [
      const HomePage(),
      const LeaderboardPage(),
      const ProgressPage(),
      SettingsPage(audioController: _audioController),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final player = _authService.currentPlayer;
    final scale = MediaQuery.of(context).size.width / 1280;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: 80 * scale,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/button_boxes/navbar.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10 * scale,
                offset: const Offset(0, -2),
              ),
            ],
          ),
        ),

        // Nav items
        Positioned(
          left: 16 * scale,
          right: 16 * scale,
          bottom: 8 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, 'assets/icons/home.png', 'Home', scale),
              _buildNavItem(
                  1, 'assets/icons/leaderboard.png', 'Leaderboard', scale),
              _buildNavItem(2, 'assets/icons/progress.png', 'Progress', scale),
              _buildNavItem(3, 'assets/icons/settings.png', 'Settings', scale),
            ],
          ),
        ),

        // Profile
        if (player != null)
          Positioned(
            left: 16 * scale,
            bottom: 6 * scale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: (scale * 0.8).clamp(0.6, 1.0),
                  child: UserMenu(
                    player: player,
                    onUpdate: _onUserStateChanged,
                  ),
                ),
                SizedBox(width: (4 * scale).clamp(2.0, 6.0)),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.username ?? 'Player',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Ari-W9500-Regular',
                          fontWeight: FontWeight.bold,
                          fontSize: 12 * scale,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: (1 * scale).clamp(0.5, 2.0)),
                      _buildScoreWidget(player, scale),
                    ],
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label, double scale) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8 * scale,
          horizontal: 12 * scale,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 32 * scale,
              height: 32 * scale,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10 * scale,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreWidget(player, double scale) {
    if (player.isGuest) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: (3 * scale).clamp(2.0, 4.0),
          vertical: (1 * scale).clamp(0.5, 1.5),
        ),
        decoration: BoxDecoration(
          color: const Color(0xF9DD9A00),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Guest',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8 * scale,
            fontFamily: 'Ari-W9500-Regular',
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FutureBuilder<int>(
      future: _gameService.getUserTotalScore(),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: (3 * scale).clamp(2.0, 5.0),
            vertical: (1 * scale).clamp(0.5, 2.0),
          ),
          decoration: BoxDecoration(
            color: const Color(0xF9DD9A00),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Score: $score',
            style: TextStyle(
              color: Colors.white,
              fontSize: (8 * scale).clamp(6.0, 10.0),
              fontFamily: 'Ari-W9500-Regular',
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
