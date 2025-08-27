import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static final AudioPlayer _player = AudioPlayer();
  static bool _enabled = true;
  static bool _loaded = false;

  static const String _assetPath = 'audio/atin_cu_pung_singsing.mp3';

  static Future<void> init({bool enabled = true}) async {
    _enabled = enabled;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.4);
    await _player.setSource(AssetSource(_assetPath));
    _loaded = true;
    if (_enabled) {
      await _player.resume();
    }
  }

  static bool get enabled => _enabled;

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;

    if (!_loaded) {
      await init(enabled: enabled);
      return;
    }

    if (enabled) {
      if (_player.state == PlayerState.stopped) {
        await _player.setSource(AssetSource(_assetPath));
      }
      if (_player.state != PlayerState.playing) {
        await _player.resume();
      }
    } else {
      if (_player.state == PlayerState.playing) {
        await _player.pause();
      }
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
