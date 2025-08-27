import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import '../../../features/progress_feature.dart';

class MitutuglungProgressScreen extends StatelessWidget {
  const MitutuglungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setMitutuglung(const MitutuglungStats(perfectPairs: 9, timeSecs: 70));
    final mit = ctrl.mit;

    final scale = MediaQuery.of(context).size.width / 1280;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: StrokeText(
                text: 'MITUTUGLUNG',
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
            BadgePill(mit.badge.label),
          ],
        ),
        SizedBox(height: 12 * scale),
        GameProgressCard(
          title: "Mitutuglung",
          p: mit,
          rowLabels: const ['Perfect Matches', 'Speed'],
          high: const ['009 pairs', '070 s'],
          xp: const ['next 10 pairs', 'next 100 s'],
        ),
      ],
    );
  }
}
