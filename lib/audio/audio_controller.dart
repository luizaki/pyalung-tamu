import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

enum _Channel { none, menu, game }

class AudioController with WidgetsBindingObserver, ChangeNotifier {
  static final AudioController _instance = AudioController._internal();
  factory AudioController() => _instance;

  final AudioPlayer _menuPlayer = AudioPlayer();
  final AudioPlayer _gamePlayer = AudioPlayer();

  static bool _enabled = true;
  static bool _loaded = false;
  _Channel _active = _Channel.none;

  static const String _menuAssetPath = 'audio/8_bit_atsing_rosing.wav';
  static const String _gameAssetPath = 'audio/atin_cu_pung_singsing_.mp3';
  static const double _menuVol = 0.45;
  static const double _gameVol = 0.45;

  static const Duration _fadeStep = Duration(milliseconds: 60);
  static const int _fadeSteps = 8;

  AudioController._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> init({bool enabled = true}) async {
    if (_loaded) return;
    _enabled = enabled;

    await _menuPlayer.setSource(AssetSource(_menuAssetPath));
    await _gamePlayer.setSource(AssetSource(_gameAssetPath));
    await _menuPlayer.setVolume(0.0);
    await _gamePlayer.setVolume(0.0);

    _loaded = true;
    notifyListeners();
  }

  bool get enabled => _enabled;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;

    if (!_loaded) {
      await init(enabled: enabled);
    }

    if (enabled) {
      await _menuPlayer.pause();
      await _gamePlayer.pause();
    } else {
      await _resumeActive();
    }
    notifyListeners();
  }

  Future<void> playMenuBgm() async {
    await _switchTo(_Channel.menu);
  }

  Future<void> playGameBgm() async {
    await _switchTo(_Channel.game);
  }

  Future<void> stopAll() async {
    await _menuPlayer.stop();
    await _gamePlayer.stop();
    _active = _Channel.none;
  }

  Future<void> _switchTo(_Channel target) async {
    if (!_loaded) await init(enabled: _enabled);
    if (!_enabled) {
      _active = target;
      return;
    }

    if (target == _active) {
      if (target == _Channel.menu) {
        await _ensurePlaying(_menuPlayer, _menuAssetPath);
        await _menuPlayer.setVolume(_menuVol);
      } else if (target == _Channel.game) {
        await _ensurePlaying(_gamePlayer, _gameAssetPath);
        await _gamePlayer.setVolume(_gameVol);
      }
      return;
    }

    // Start target (muted), fade out the other.
    if (target == _Channel.menu) {
      await _ensurePlaying(_menuPlayer, _menuAssetPath);
      await _crossFade(
          from: _gamePlayer,
          to: _menuPlayer,
          fromVol: _gameVol,
          toVol: _menuVol);
      _active = _Channel.menu;
    } else {
      await _ensurePlaying(_gamePlayer, _gameAssetPath);
      await _crossFade(
          from: _menuPlayer,
          to: _gamePlayer,
          fromVol: _menuVol,
          toVol: _gameVol);
      _active = _Channel.game;
    }

    notifyListeners();
  }

  Future<void> _ensurePlaying(AudioPlayer player, String asset) async {
    if (player.state == PlayerState.playing) return;
    if (player.state == PlayerState.paused) {
      await player.resume();
      return;
    }
    await player.stop();
    await player.setSource(AssetSource(asset));
    await player.resume();
  }

  Future<void> _crossFade({
    required AudioPlayer from,
    required AudioPlayer to,
    required double fromVol,
    required double toVol,
  }) async {
    await to.setVolume(0.0);

    if (to.state != PlayerState.playing) {
      await to.resume();
    }

    for (int i = 0; i <= _fadeSteps; i++) {
      final t = i / _fadeSteps;
      await from.setVolume(fromVol * (1.0 - t));
      await to.setVolume(toVol * t);
      await Future.delayed(_fadeStep);
    }

    await from.pause();
    await from.setVolume(0.0);
    await to.setVolume(toVol);
  }

  Future<void> _resumeActive() async {
    switch (_active) {
      case _Channel.menu:
        await _ensurePlaying(_menuPlayer, _menuAssetPath);
        await _menuPlayer.setVolume(_menuVol);
        break;
      case _Channel.game:
        await _ensurePlaying(_gamePlayer, _gameAssetPath);
        await _gamePlayer.setVolume(_gameVol);
        break;
      case _Channel.none:
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _menuPlayer.pause();
      _gamePlayer.pause();
    } else if (state == AppLifecycleState.resumed && _enabled) {
      _resumeActive();
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _menuPlayer.dispose();
    await _gamePlayer.dispose();
    super.dispose();
  }
}
