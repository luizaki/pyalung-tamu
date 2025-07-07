import 'package:flutter/material.dart';

import '../widgets/main_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        children: [
          // Title
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(
                            value: 'Filipino', child: Text('Filipino')),
                      ],
                      onChanged: (newValue) {},
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
