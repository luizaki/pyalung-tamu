import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../widgets/main_screen.dart';
import '../audio/audio_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _musicEnabled = AudioController.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        contentWidthFactor: 0.70,
        children: [
          Center(
            child: StrokeText(
              text: 'Settings',
              textStyle: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFCF7D0),
              ),
              strokeColor: Colors.black,
              strokeWidth: 4,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingCard(
            icon: Icons.volume_up,
            label: 'Sound Effects',
            trailing: Transform.scale(
              scale: 1.6,
              child: Switch(
                value: _sfxEnabled,
                onChanged: (v) => setState(() => _sfxEnabled = v),
              ),
            ),
          ),
          _buildSettingCard(
            icon: Icons.music_note,
            label: 'Background Music',
            trailing: Transform.scale(
              scale: 1.6,
              child: Switch(
                value: _musicEnabled,
                onChanged: (v) async {
                  setState(() => _musicEnabled = v);
                  try {
                    await AudioController.setEnabled(v);
                  } catch (e) {
                    setState(() => _musicEnabled = !v);
                  }
                },
              ),
            ),
          ),
          _buildSettingCard(
            icon: Icons.language,
            label: 'Language',
            trailing: DropdownButton<String>(
              value: _language,
              isDense: false,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(
                    value: 'Kapampangan', child: Text('Kapampangan')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'English'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      color: const Color(0xFFF4BE0A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown, size: 56),
            const SizedBox(width: 20),
            Expanded(
              child: StrokeText(
                text: label,
                textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFCF7D0),
                ),
                strokeColor: Colors.black,
                strokeWidth: 3.5,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            trailing,
          ],
        ),
      ),
    );
  }
}
