import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../../../features/progress_feature.dart';

class OverallProgressScreen extends StatelessWidget {
  const OverallProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setSiglulung(const SiglulungStats(wpm: 62, accuracy: 93))
      ..setTugak(const TugakStats(fluency: 18, accuracy: 88))
      ..setMitutuglung(const MitutuglungStats(perfectPairs: 9, timeSecs: 70));

    final scale = MediaQuery.of(context).size.width / 1280;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: StrokeText(
                text: 'OVERALL PROGRESS',
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
            BadgePill(ctrl.macro.label),
          ],
        ),
        SizedBox(height: 12 * scale),
        MacroProgressTable(
          c: ctrl,
          high: const ['062 WPM', '018 words', '009 pairs'],
          last: const ['058', '016', '008'],
        ),
      ],
    );
  }
}
