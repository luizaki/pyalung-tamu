import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../../../features/progress_feature.dart';

class TugakProgressScreen extends StatelessWidget {
  const TugakProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setTugak(const TugakStats(fluency: 18, accuracy: 88));
    final tug = ctrl.tug;

    final scale = MediaQuery.of(context).size.width / 1280;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: StrokeText(
                text: 'TUGAK CATCHING',
                textStyle: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFCF7D0),
                ),
                strokeColor: Colors.black,
                strokeWidth: 2 * scale,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12 * scale),
            BadgePill(tug.badge.label),
          ],
        ),
        SizedBox(height: 12 * scale),
        GameProgressCard(
          title: "Tugak Catching",
          p: tug,
          rowLabels: const ['Fluency', 'Accuracy'],
          high: const ['018 words', '088 %'],
          xp: const ['next 20 words', 'next 90 %'],
        ),
      ],
    );
  }
}
