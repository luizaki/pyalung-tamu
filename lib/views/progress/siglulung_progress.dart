import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';

class SiglulungProgressScreen extends StatelessWidget {
  const SiglulungProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setSiglulung(const SiglulungStats(wpm: 62, accuracy: 93));

    final sig = ctrl.sig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SIGLULUNG',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            BadgePill(sig.badge.label),
          ],
        ),
        const SizedBox(height: 12),
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
