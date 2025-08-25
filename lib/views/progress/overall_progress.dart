import 'package:flutter/material.dart';
import '../../../features/progress_feature.dart';
import 'progress.dart';

class OverallProgressScreen extends StatelessWidget {
  const OverallProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ProgressController()
      ..setSiglulung(const SiglulungStats(wpm: 62, accuracy: 93))
      ..setTugak(const TugakStats(fluency: 18, accuracy: 88))
      ..setMitutuglung(const MitutuglungStats(perfectPairs: 9, timeSecs: 70));

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
                  'OVERALL PROGRESS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                BadgePill(ctrl.macro.label),
              ],
            ),
            const SizedBox(height: 12),
            ProgressCard(
              child: MacroProgressTable(
                c: ctrl,
                high: const ['062 WPM', '018 words', '009 pairs'],
                last: const ['058', '016', '008'],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
