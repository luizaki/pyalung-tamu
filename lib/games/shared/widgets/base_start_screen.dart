import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/multiplayer_service.dart';
import '../../../services/auth_service.dart';

const Size _screenSize = Size(1280, 720);

class StartScreen extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final String gameTitle;
  final String instructions;

  final Widget gameScreen;
  final String? backgroundImage;
  final String? gameIcon;

  final String?
      gameType; // 'siglulung_bangka' | 'tugak_catching' | 'mitutuglung'
  final Widget Function(String matchId)? multiplayerBuilder;

  final bool? isGuestOverride;

  const StartScreen({
    super.key,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.gameTitle,
    required this.instructions,
    required this.gameScreen,
    this.backgroundImage,
    this.gameIcon,
    this.gameType,
    this.multiplayerBuilder,
    this.isGuestOverride,
  });

  bool get _multiplayerEnabled =>
      gameType != null && multiplayerBuilder != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: backgroundImage != null
                ? Image.asset(backgroundImage!, fit: BoxFit.cover)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color1,
                          color1,
                          color2,
                          color2,
                          color3,
                          color3,
                          color4,
                          color4
                        ],
                        stops: const [0, .25, .25, .5, .5, .75, .75, 1],
                      ),
                    ),
                  ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final scaleW = size.width / _screenSize.width;
                final scaleH = size.height / _screenSize.height;
                final rawScale = (scaleW + scaleH) / 2;
                final scale = rawScale.clamp(0.65, 1.1);

                final circleDim = (200.0 * scale).toDouble();
                final circleBorder = (10.0 * scale).toDouble();
                final backBtnSize = (55.0 * scale).toDouble();
                final backBtnBorder = (2.0 * scale).toDouble();
                final backIconSize = (30.0 * scale).toDouble();
                final backTop = (20.0 * scale).toDouble();
                final backLeft = (20.0 * scale).toDouble();

                final titleSize = (64.0 * scale).clamp(28.0, 64.0).toDouble();
                final titleStroke = (6.0 * scale).clamp(2.0, 6.0).toDouble();
                final instrSize = (28.0 * scale).clamp(12.0, 20.0).toDouble();
                final instrStroke = (4.0 * scale).clamp(0.5, 2.0).toDouble();

                final outerBorder = (5.0 * scale).toDouble();
                final cardRadius = (16.0 * scale).toDouble();
                final playPadding = (12.0 * scale).toDouble();
                final playFont = (22.0 * scale).clamp(16.0, 22.0).toDouble();

                final maxContentWidth = 920.0;
                final playWidth =
                    (420.0 * scale).clamp(260.0, size.width * 0.86).toDouble();

                final gap = (12.0 * scale).toDouble();
                final btnWidth =
                    _multiplayerEnabled ? (playWidth - gap) / 2 : playWidth;

                final firstLine = instructions.split('\n').first.trim();
                final spacingAfterInstruction =
                    (instrSize * 1.35).clamp(18.0, 40.0).toDouble();

                return Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                            minHeight: constraints.maxHeight - 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10 * scale),
                                width: circleDim,
                                height: circleDim,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF9DD9A),
                                  border: Border.all(
                                      color: const Color(0xFFAD5721),
                                      width: circleBorder),
                                ),
                                child: gameIcon != null
                                    ? ClipOval(
                                        child: Image.asset(gameIcon!,
                                            fit: BoxFit.cover))
                                    : Icon(Icons.games,
                                        size: 100 * scale, color: Colors.brown),
                              ),
                              SizedBox(height: 16 * scale),
                              StrokeText(
                                text: gameTitle,
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  fontSize: titleSize,
                                  fontFamily: 'Ari-W9500-Display',
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFF4BE0A),
                                ),
                                strokeColor: Colors.black,
                                strokeWidth: titleStroke,
                              ),
                              SizedBox(height: 24 * scale),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20 * scale),
                                child: StrokeText(
                                  text: 'How to Play: $firstLine',
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(
                                    fontSize: instrSize,
                                    height: 1.2,
                                    fontFamily: 'Ari-W9500-Display',
                                    fontWeight: FontWeight.w100,
                                    color: const Color(0xFFFFFEDE),
                                  ),
                                  strokeColor: Colors.black,
                                  strokeWidth: instrStroke,
                                ),
                              ),
                              SizedBox(height: spacingAfterInstruction),
                              SizedBox(
                                width: playWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: btnWidth,
                                      child: _PrimaryButton(
                                        label: 'Solo Play',
                                        outerBorder: outerBorder,
                                        cardRadius: cardRadius,
                                        playPadding: playPadding,
                                        playFont: playFont,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    gameScreen),
                                          );
                                        },
                                      ),
                                    ),
                                    if (_multiplayerEnabled) ...[
                                      SizedBox(width: gap),
                                      SizedBox(
                                        width: btnWidth,
                                        child: _PrimaryButton(
                                          label: 'Join Match',
                                          outerBorder: outerBorder,
                                          cardRadius: cardRadius,
                                          playPadding: playPadding,
                                          playFont: playFont,
                                          onTap: () async {
                                            final bool isGuest =
                                                isGuestOverride ??
                                                    (() {
                                                      try {
                                                        return AuthService()
                                                            .isGuest;
                                                      } catch (_) {
                                                        return Supabase
                                                                .instance
                                                                .client
                                                                .auth
                                                                .currentUser ==
                                                            null;
                                                      }
                                                    })();

                                            if (isGuest ||
                                                Supabase.instance.client.auth
                                                        .currentUser ==
                                                    null) {
                                              _showMustLogin(context, scale);
                                              return;
                                            }
                                            if (gameType == null ||
                                                multiplayerBuilder == null) {
                                              return;
                                            }

                                            _showJoiningDialog(context, scale);
                                            try {
                                              final matchId =
                                                  await MultiplayerService()
                                                      .quickMatch(gameType!);
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        multiplayerBuilder!(
                                                            matchId),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to join match: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: backTop,
                      left: backLeft,
                      child: Container(
                        width: backBtnSize,
                        height: backBtnSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2BB495),
                          border: Border.all(
                              color: const Color(0xFF443229),
                              width: backBtnBorder),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: const Color(0xFFF4BE0A),
                              size: backIconSize),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showJoiningDialog(BuildContext context, double scale) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Joining match',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, a1, a2) {
        return Center(
          child: _PromptCard(
            scale: scale,
            title: 'Matchmaking',
            message: 'Finding a match...',
            showSpinner: true,
            onOk: null,
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _showMustLogin(BuildContext context, double scale) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Login required',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, a1, a2) {
        return Center(
          child: _PromptCard(
            scale: scale,
            title: 'Guest Mode',
            message: 'Log in or create an account to view your progress',
            showSpinner: false,
            onOk: () => Navigator.of(ctx).pop(),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final double outerBorder;
  final double cardRadius;
  final double playPadding;
  final double playFont;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.outerBorder,
    required this.cardRadius,
    required this.playPadding,
    required this.playFont,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minHeight = (playFont * 2.2).clamp(44.0, 56.0);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Material(
        color: const Color(0xF9DD9A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: const Color(0xAD572100), width: outerBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius)),
          highlightColor: const Color(0xFFCA8505),
          child: Center(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: playPadding, horizontal: 14),
              child: Text(
                label,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: playFont,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  color: const Color(0xFFF9DD9A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final double scale;
  final String title;
  final String message;
  final bool showSpinner;
  final VoidCallback? onOk;

  const _PromptCard({
    required this.scale,
    required this.title,
    required this.message,
    required this.showSpinner,
    this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = (12.0 * scale).toDouble();
    final borderW = (6.0 * scale).clamp(3.0, 8.0).toDouble();
    final padH = (24.0 * scale).clamp(18.0, 28.0).toDouble();
    final padV = (22.0 * scale).clamp(16.0, 26.0).toDouble();
    final titleSize = (64.0 * scale).clamp(28.0, 48.0).toDouble();
    final titleStroke = (4.0 * scale).clamp(2.0, 4.0).toDouble();
    final bodySize = (16.0 * scale).clamp(14.0, 18.0).toDouble();

    return Container(
      constraints: const BoxConstraints(maxWidth: 760),
      margin: EdgeInsets.symmetric(horizontal: 24 * scale),
      decoration: BoxDecoration(
        color: const Color(0xF9DD9A00),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: const Color(0xAD572100), width: borderW),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 20 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StrokeText(
                        text: title,
                        textStyle: TextStyle(
                          fontSize: titleSize,
                          fontFamily: 'Ari-W9500-Display',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFCF7D0),
                        ),
                        strokeColor: Colors.black,
                        strokeWidth: titleStroke,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        message,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: bodySize,
                          color: const Color(0xFF3A2A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showSpinner) ...[
                  SizedBox(width: 16 * scale),
                  SizedBox(
                    width: 28 * scale,
                    height: 28 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: (3.0 * scale).clamp(2.0, 3.5),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.brown),
                      backgroundColor: const Color(0xFFFFF2C5),
                    ),
                  ),
                ],
              ],
            ),
            if (onOk != null) ...[
              SizedBox(height: 16 * scale),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: (180 * scale).clamp(140, 220).toDouble(),
                  child: _PrimaryButton(
                    label: 'OK',
                    outerBorder: (4.0 * scale).toDouble(),
                    cardRadius: (12.0 * scale).toDouble(),
                    playPadding: (10.0 * scale).toDouble(),
                    playFont: (18.0 * scale).clamp(16.0, 20.0).toDouble(),
                    onTap: onOk!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
