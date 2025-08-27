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
    final scale = MediaQuery.of(context).size.width / 1280;

    return Scaffold(
      body: MainScreen(
        contentWidthFactor: 0.55,
        children: [
          Center(
            child: StrokeText(
              text: 'Settings',
              textStyle: TextStyle(
                fontSize: 50 * scale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFCF7D0),
              ),
              strokeColor: Colors.black,
              strokeWidth: 4,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            icon: Icons.volume_up,
            label: 'Sound Effects',
            scale: scale,
            trailing: Switch(
              value: _sfxEnabled,
              onChanged: (v) => setState(() => _sfxEnabled = v),
            ),
          ),
          _buildSettingCard(
            icon: Icons.music_note,
            label: 'Background Music',
            scale: scale,
            trailing: Switch(
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
          _buildSettingCard(
            icon: Icons.language,
            label: 'Language',
            scale: scale,
            trailing: DropdownButton<String>(
              value: _language,
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
    required double scale,
    required Widget trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFFF4BE0A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18 * scale),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown, size: 34 * scale),
            const SizedBox(width: 18),
            Expanded(
              child: StrokeText(
                text: label,
                textStyle: TextStyle(
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFCF7D0),
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
