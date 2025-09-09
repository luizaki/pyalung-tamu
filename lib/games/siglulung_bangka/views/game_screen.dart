import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets/base_game_screen.dart';
import '../controllers/game_controller.dart';

import '../widgets/boat_widget.dart';
import '../widgets/background.dart';
import '../widgets/word_queue.dart';
import './multiplayer_screen.dart' show SiglulungMultiplayerAdapter;

class BangkaGameScreen extends BaseGameScreen<BangkaGameController> {
  final String? multiplayerMatchId;
  final SiglulungMultiplayerAdapter? multiplayerAdapter;
  final Future<void> Function()? onPlayAgain;

  const BangkaGameScreen({
    super.key,
    this.multiplayerMatchId,
    this.multiplayerAdapter,
    this.onPlayAgain,
  }) : super(
          isMultiplayer: multiplayerMatchId != null,
          onPlayAgain: onPlayAgain,
        );

  @override
  BangkaGameScreenState createState() => BangkaGameScreenState();
}

class BangkaGameScreenState
    extends BaseGameScreenState<BangkaGameController, BangkaGameScreen>
    with WidgetsBindingObserver {
  final FocusNode _imeFocus = FocusNode();
  final TextEditingController _imeController = TextEditingController();

  TextEditingValue _prevValue = const TextEditingValue();
  bool _sentFinish = false;

  @override
  List<Color> get backgroundColors => const [
        Color(0xFF87CEEB),
        Color(0xFF4682B4),
      ];

  @override
  bool get isMultiplayer => widget.multiplayerMatchId != null;

  @override
  BangkaGameController createController() => BangkaGameController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    RawKeyboard.instance.addListener(_handleRawKey);
  }

  @override
  void setupController() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureIme());
  }

  @override
  void onControllerUpdate() {
    _ensureIme();

    final adapter = widget.multiplayerAdapter;
    if (adapter != null) {
      final int wpm = controller.getSecondaryScore();
      final double acc =
          (controller.gameState.accuracy * 100.0).clamp(0.0, 100.0);
      adapter.updateStats(wpm: wpm, accuracy: acc);
    }

    if (controller.isGameOver && !_sentFinish) {
      _sentFinish = true;
      widget.multiplayerAdapter?.finish();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _ensureIme();
  }

  void _ensureIme() {
    if (!mounted) return;
    if (!_imeFocus.hasFocus) _imeFocus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  void disposeGameSpecific() {
    WidgetsBinding.instance.removeObserver(this);
    RawKeyboard.instance.removeListener(_handleRawKey);
    _imeFocus.dispose();
    _imeController.dispose();
  }

  @override
  List<Widget> buildGameSpecificWidgets() {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final kb = mq.viewInsets.bottom;
    final visibleSize =
        Size(size.width, (size.height - kb).clamp(0, size.height));

    final kbRatio = (kb / size.height).clamp(0.0, 0.6);
    final liftForSprites = kb * (0.55 + 0.25 * kbRatio);

    return [
      // Background
      MovingBackground(
        boatSpeed: controller.boatSpeed,
        screenSize: visibleSize,
        isGameActive: controller.isGameActive,
      ),

      // Boat
      Positioned.fill(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: liftForSprites),
          child: BoatWidget(
            boat: controller.gameState.boat,
            screenSize: visibleSize,
          ),
        ),
      ),

      _buildWordQueueArea(keyboardHeight: kb),

      //hidden input field
      _buildHiddenIME(),
    ];
  }

  Widget _buildWordQueueArea({required double keyboardHeight}) {
    return Positioned.fill(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalH = constraints.maxHeight;
            final usableH =
                (constraints.maxHeight - keyboardHeight).clamp(0, totalH);

            final topFrac = keyboardHeight > 0 ? 0.05 : 0.10;
            final minTop = keyboardHeight > 0 ? 32.0 : 64.0;
            final maxTop = keyboardHeight > 0 ? 140.0 : 240.0;
            final topOffset = (usableH * topFrac).clamp(minTop, maxTop);

            final widthFactor = keyboardHeight > 0 ? 0.68 : 0.72;
            final contentWidth =
                (constraints.maxWidth * widthFactor).clamp(260.0, 1100.0);

            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: topOffset),
                child: Container(
                  width: contentWidth,
                  alignment: Alignment.centerLeft,
                  child: WordQueueDisplay(
                    currentWord: controller.gameState.currentWord,
                    upcomingWords: controller.upcomingWords,
                    screenWidth: contentWidth,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHiddenIME() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _ensureIme,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 1,
            height: 1,
            child: EditableText(
              controller: _imeController,
              focusNode: _imeFocus,
              autofocus: true,
              readOnly: false,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.none,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              cursorColor: Colors.transparent,
              backgroundCursorColor: Colors.transparent,
              style: const TextStyle(fontSize: 1, height: 1),
              onChanged: (_) => _handleValueChanged(_imeController.value),
              onSubmitted: (_) {
                controller.onKeyPressed(' ');
                _ensureIme();
              },
              onEditingComplete: _ensureIme,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleValueChanged(TextEditingValue v) {
    if (v.composing.isValid) return;

    final prev = _prevValue;
    final d = v.text.length - prev.text.length;

    if (d > 0) {
      final inserted = v.text.substring(prev.text.length);
      for (final cu in inserted.codeUnits) {
        controller.onKeyPressed(String.fromCharCode(cu));
      }
    }

    _prevValue = v;

    if (_imeController.text.length > 32) {
      _imeController.clear();
      _prevValue = const TextEditingValue();
      _ensureIme();
    }
  }

  void _handleRawKey(RawKeyEvent e) {
    if (e is! RawKeyDownEvent) return;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      controller.onKeyPressed('Backspace');
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      controller.onKeyPressed(' ');
    }
  }
}
