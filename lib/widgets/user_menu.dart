import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../models/player.dart';

import './avatar_selector.dart';
import './auth_popup.dart';

class UserMenu extends StatefulWidget {
  final Player player;
  final VoidCallback onUpdate;

  const UserMenu({
    super.key,
    required this.player,
    required this.onUpdate,
  });

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset:
          widget.player.isGuest ? const Offset(0, -120) : const Offset(0, -180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: const Color(0xFFF4BE0A),
      itemBuilder: (context) => [
        // User info header
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.player.username ?? 'Player',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                  fontSize: 16,
                ),
              ),
              if (!widget.player.isGuest) ...[
                Text(
                  widget.player.email ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xAA795548),
                  ),
                ),
              ] else ...[
                const Text(
                  'Guest Account',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xAA795548),
                  ),
                ),
              ],
              const Divider(
                color: Color(0xAD572100),
              ),
            ],
          ),
        ),

        // Change Avatar (only for logged-in users)
        if (!widget.player.isGuest)
          const PopupMenuItem<String>(
            value: 'change_avatar',
            child: Row(
              children: [
                Icon(Icons.face, size: 20),
                SizedBox(width: 8),
                Text('Change Avatar',
                    style: TextStyle(
                      fontSize: 12,
                    )),
              ],
            ),
          ),

        // Logout
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                widget.player.isGuest ? Icons.exit_to_app : Icons.logout,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.player.isGuest ? 'Exit Guest Mode' : 'Logout',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
      onSelected: _handleMenuSelection,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/avatar/${widget.player.avatar ?? 'boy.PNG'}',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'change_avatar':
        _showAvatarSelector();
        break;
      case 'login':
        _showAuthPopup();
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  void _showAvatarSelector() {
    showDialog(
      context: context,
      builder: (context) => AvatarSelector(
        currentAvatar: widget.player.avatar,
        onAvatarSelected: _handleAvatarChange,
      ),
    );
  }

  Future<void> _handleAvatarChange(String newAvatar) async {
    final result = await _authService.updateAvatar(newAvatar);

    if (result.isSuccess) {
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAuthPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AuthPopup(),
    ).then((result) {
      if (result == true) {
        widget.onUpdate();
      }
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    widget.onUpdate();

    if (widget.player.isGuest) {
      // If was guest, show auth popup again
      _showAuthPopup();
    }
  }
}
