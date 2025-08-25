import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';
import 'progress.dart';

class MitutuglungProgressScreen extends StatelessWidget {
  const MitutuglungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setMitutuglung(const MitutuglungStats(perfectPairs: 9, timeSecs: 70));

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg/card_bgSmallFlag.PNG',
            fit: BoxFit.cover,
          ),
        ),
        ProgressBox(
          children: [
            Row(
              children: [
                const Text(
                  'MITUTUGLUNG',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                BadgePill(ctrl.mit.badge.label),
              ],
            ),
            const SizedBox(height: 12),
            ProgressCard(
              child: GameProgressCard(
                title: 'MITUTUGLUNG',
                p: ctrl.mit,
                rowLabels: const ['Perfect Matches', 'Speed'],
                high: const ['009 pairs', '070s'],
                xp: const ['next 10 pairs', 'next ≤75s'],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
