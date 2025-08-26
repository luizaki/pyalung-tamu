import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';

class TugakProgressScreen extends StatelessWidget {
  const TugakProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setTugak(const TugakStats(fluency: 18, accuracy: 88));

    final tug = ctrl.tug;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'TUGAK CATCHING',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            BadgePill(tug.badge.label),
          ],
        ),
        const SizedBox(height: 12),
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
