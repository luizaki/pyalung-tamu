import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';

class MitutuglungProgressScreen extends StatelessWidget {
  const MitutuglungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setMitutuglung(const MitutuglungStats(perfectPairs: 9, timeSecs: 70));

    final mit = ctrl.mit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'MITUTUGLUNG',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            BadgePill(mit.badge.label),
          ],
        ),
        const SizedBox(height: 12),
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
