import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../../../features/progress_feature.dart';

class SiglulungProgressScreen extends StatelessWidget {
  const SiglulungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setSiglulung(const SiglulungStats(wpm: 62, accuracy: 93));

    final sig = ctrl.sig;
    final scale = MediaQuery.of(context).size.width / 1280;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: StrokeText(
                text: 'SIGLULUNG',
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
            BadgePill(sig.badge.label),
          ],
        ),
        SizedBox(height: 12 * scale),
        GameProgressCard(
          title: "Siglulung",
          p: sig,
          rowLabels: const ['Speed', 'Accuracy'],
          high: const ['062 WPM', '093 %'],
          xp: const ['next 70 WPM', 'next 97 %'],
        ),
      ],
    );
  }
}
