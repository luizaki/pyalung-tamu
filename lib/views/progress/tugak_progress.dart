import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';
import 'progress.dart';

class TugakProgressScreen extends StatelessWidget {
  const TugakProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setTugak(const TugakStats(fluency: 18, accuracy: 88));

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg/tugak_bgSmallFlag.PNG',
            fit: BoxFit.cover,
          ),
        ),
        ProgressBox(
          children: [
            Row(
              children: [
                const Text(
                  'TUGAK CATCHING',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                BadgePill(ctrl.tug.badge.label),
              ],
            ),
            const SizedBox(height: 12),
            ProgressCard(
              child: GameProgressCard(
                title: 'TUGAK CATCHING',
                p: ctrl.tug,
                rowLabels: const ['Fluency', 'Accuracy'],
                high: const ['018 words', '088 %'],
                xp: const ['next 20 words', 'next 90 %'],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
