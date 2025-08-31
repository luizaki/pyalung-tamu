import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../widgets/main_screen.dart';
import '../audio/audio_controller.dart';

class SettingsPage extends StatefulWidget {
  final AudioController audioController;

  const SettingsPage({super.key, required this.audioController});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _musicEnabled;

  @override
  void initState() {
    super.initState();

    _musicEnabled = widget.audioController.enabled;

    widget.audioController.addListener(_onAudioChanged);
  }

  @override
  void dispose() {
    widget.audioController.removeListener(_onAudioChanged);
    super.dispose();
  }

  void _onAudioChanged() {
    if (mounted) {
      setState(() => _musicEnabled = widget.audioController.enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(
        contentWidthFactor: 0.70,
        children: [
          const Center(
            child: StrokeText(
              text: 'Settings',
              textStyle: TextStyle(
                fontSize: 64,
                fontFamily: 'Ari-W9500-Display',
                fontWeight: FontWeight.w500,
                color: Color(0xFFFCF7D0),
              ),
              strokeColor: Colors.black,
              strokeWidth: 4,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingCard(
            icon: Icons.music_note,
            label: 'Background Music',
            trailing: AnimatedBuilder(
              animation: widget.audioController,
              builder: (context, _) {
                return Transform.scale(
                  scale: 1.6,
                  child: Switch(
                    value: widget.audioController.enabled,
                    onChanged: (v) {
                      widget.audioController.setEnabled(v);
                    },
                    //activeThumbColor: Colors.brown,
                    activeTrackColor: const Color(0xFF2BB495),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'Created by FARM. Lee, Sanchez, Santos, Baquiano.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                  fontSize: 30,
                  fontFamily: 'Ari-W9500-Display',
                  fontWeight: FontWeight.w200,
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
