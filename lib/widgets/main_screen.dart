import 'package:flutter/material.dart';

const Size _kDesign = Size(1280, 720);

class MainScreen extends StatelessWidget {
  final List<Widget> children;
  final String? background;
  final double contentWidthFactor;

  final Size designSize;

  const MainScreen({
    super.key,
    required this.children,
    this.background,
    this.contentWidthFactor = 0.78,
    this.designSize = _kDesign,
  });

  @override
  Widget build(BuildContext context) {
    final double designW = designSize.width;
    final double designH = designSize.height;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            background ?? 'assets/bg/bg_simple.png',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: designW,
                height: designH,
                child: Center(
                  child: SizedBox(
                    width: (designW * contentWidthFactor.clamp(0.45, 0.95)),
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xF9DD9A00),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xAD572100),
                          width: 10,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xAD572100).withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: _MainContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final main = context.findAncestorWidgetOfExactType<MainScreen>();
    final items = main?.children ?? const <Widget>[];
    return Column(mainAxisSize: MainAxisSize.min, children: items);
  }
}
