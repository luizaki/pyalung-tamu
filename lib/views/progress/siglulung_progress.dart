import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';
import 'progress.dart';

class SiglulungProgressScreen extends StatelessWidget {
  const SiglulungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setSiglulung(const SiglulungStats(wpm: 62, accuracy: 93));

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg/boat_bgSmallFlag.PNG',
            fit: BoxFit.cover,
          ),
        ),
        ProgressBox(
          children: [
            Row(
              children: [
                const Text(
                  'SIGLULUNG',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                BadgePill(ctrl.sig.badge.label),
              ],
            ),
            const SizedBox(height: 12),
            ProgressCard(
              child: GameProgressCard(
                title: 'SIGLULUNG',
                p: ctrl.sig,
                rowLabels: const ['Speed', 'Accuracy'],
                high: const ['062 WPM', '093 %'],
                xp: const ['next 70 WPM', 'next 97 %'],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
