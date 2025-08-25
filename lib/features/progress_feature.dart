import 'package:flutter/material.dart';

//levels

enum Level { none, beginner, intermediate, expert }

extension LevelX on Level {
  int get v => index;
  String get label => switch (this) {
        Level.none => 'None',
        Level.beginner => 'Beginner',
        Level.intermediate => 'Intermediate',
        Level.expert => 'Expert',
      };
}

class SiglulungStats {
  final double wpm, accuracy;
  const SiglulungStats({required this.wpm, required this.accuracy});
}

class TugakStats {
  final int fluency;
  final double accuracy;
  const TugakStats({required this.fluency, required this.accuracy});
}

class MitutuglungStats {
  final int perfectPairs;
  final int timeSecs;
  const MitutuglungStats({required this.perfectPairs, required this.timeSecs});
}

class GameProgress {
  final Level metricA, metricB, badge;
  final double progA, progB;
  const GameProgress(
      this.metricA, this.metricB, this.badge, this.progA, this.progB);
}

//thresholds

class Thresholds {
  // Siglulung
  static const wpm = [30, 50, 70];
  static const sigAccuracy = [85, 92, 97];

  // Tugak Catching
  static const fluency = [10, 20, 35];
  static const tugAccuracy = [80, 90, 95];

  // Mitutuglung
  static const perfectPairs = [6, 10, 14];
  static const timeSecs = [120, 75, 45];
}

Level _inc(num v, List<num> t) {
  if (v >= t[2]) return Level.expert;
  if (v >= t[1]) return Level.intermediate;
  if (v >= t[0]) return Level.beginner;
  return Level.none;
}

Level _dec(num v, List<num> t) {
  if (v <= t[2]) return Level.expert;
  if (v <= t[1]) return Level.intermediate;
  if (v <= t[0]) return Level.beginner;
  return Level.none;
}

double _pUp(num v, List<num> t) {
  if (v < t[0]) return (v / t[0]).clamp(0, 1).toDouble();
  if (v < t[1]) return ((v - t[0]) / (t[1] - t[0])).clamp(0, 1).toDouble();
  if (v < t[2]) return ((v - t[1]) / (t[2] - t[1])).clamp(0, 1).toDouble();
  return 1;
}

double _pDown(num v, List<num> t) {
  if (v > t[0]) return (t[0] / v).clamp(0, 1).toDouble();
  if (v > t[1]) return ((v - t[1]) / (t[0] - t[1])).clamp(0, 1).toDouble();
  if (v > t[2]) return ((v - t[2]) / (t[1] - t[2])).clamp(0, 1).toDouble();
  return 1;
}

//stats
GameProgress evalSiglulung(SiglulungStats s) {
  final a = _inc(s.wpm, Thresholds.wpm);
  final b = _inc(s.accuracy, Thresholds.sigAccuracy);
  final badge = (a.v <= b.v) ? a : b;
  return GameProgress(a, b, badge, _pUp(s.wpm, Thresholds.wpm),
      _pUp(s.accuracy, Thresholds.sigAccuracy));
}

GameProgress evalTugak(TugakStats s) {
  final a = _inc(s.fluency, Thresholds.fluency);
  final b = _inc(s.accuracy, Thresholds.tugAccuracy);
  final badge = (a.v <= b.v) ? a : b;
  return GameProgress(a, b, badge, _pUp(s.fluency, Thresholds.fluency),
      _pUp(s.accuracy, Thresholds.tugAccuracy));
}

GameProgress evalMitutuglung(MitutuglungStats s) {
  final a = _inc(s.perfectPairs, Thresholds.perfectPairs);
  final b = _dec(s.timeSecs, Thresholds.timeSecs);
  final badge = (a.v <= b.v) ? a : b;
  return GameProgress(
      a,
      b,
      badge,
      _pUp(s.perfectPairs, Thresholds.perfectPairs),
      _pDown(s.timeSecs, Thresholds.timeSecs));
}

Level evalMacro(GameProgress g1, GameProgress g2, GameProgress g3) {
  final avg = (g1.badge.v + g2.badge.v + g3.badge.v) / 3.0;
  final i = avg < 0.5
      ? 0
      : avg < 1.5
          ? 1
          : avg < 2.5
              ? 2
              : 3;
  return Level.values[i];
}

//controller

class ProgressController {
  SiglulungStats? _sig;
  TugakStats? _tug;
  MitutuglungStats? _mit;

  void setSiglulung(SiglulungStats s) => _sig = s;
  void setTugak(TugakStats s) => _tug = s;
  void setMitutuglung(MitutuglungStats s) => _mit = s;

  GameProgress get sig =>
      evalSiglulung(_sig ?? const SiglulungStats(wpm: 0, accuracy: 0));
  GameProgress get tug =>
      evalTugak(_tug ?? const TugakStats(fluency: 0, accuracy: 0));
  GameProgress get mit => evalMitutuglung(
      _mit ?? const MitutuglungStats(perfectPairs: 0, timeSecs: 9999));

  Level get macro => evalMacro(sig, tug, mit);
}

//ui widget

class BadgePill extends StatelessWidget {
  final String text;
  const BadgePill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (text) {
      'Expert' => Colors.amber,
      'Intermediate' => Colors.orangeAccent,
      'Beginner' => Colors.lightBlueAccent,
      _ => Theme.of(context).disabledColor.withOpacity(.25),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black54, width: 1.2),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class ProgressRow extends StatelessWidget {
  final String level, skill, high, xp;
  final double progress;
  const ProgressRow({
    super.key,
    required this.level,
    required this.skill,
    required this.high,
    required this.xp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 92, child: Text(level)),
          Expanded(child: Text(skill)),
          SizedBox(width: 110, child: Text(high, textAlign: TextAlign.center)),
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 4, 209, 148)),
                  backgroundColor: const Color(0xAD572100),
                ),
                const SizedBox(height: 4),
                Text(xp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameProgressCard extends StatelessWidget {
  final String title;
  final GameProgress p;
  final List<String> rowLabels;
  final List<String> high;
  final List<String> xp;

  const GameProgressCard({
    super.key,
    required this.title,
    required this.p,
    required this.rowLabels,
    required this.high,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Expanded(child: Text('Level')),
              Expanded(child: Text('Skill')),
              Expanded(child: Text('High Score')),
              Expanded(child: Text('XP to Level Up')),
            ]),
            const Divider(
              color: const Color(0xAD572100),
            ),
            const SizedBox(height: 10),
            ProgressRow(
              level: p.metricA.label,
              skill: rowLabels[0],
              high: high[0],
              xp: xp[0],
              progress: p.progA,
            ),
            ProgressRow(
              level: p.metricB.label,
              skill: rowLabels[1],
              high: high[1],
              xp: xp[1],
              progress: p.progB,
            ),
          ],
        ),
      ),
    );
  }
}

class MacroProgressTable extends StatelessWidget {
  final ProgressController c;
  final List<String> high; //score
  final List<String> last; //score
  const MacroProgressTable(
      {super.key, required this.c, required this.high, required this.last});

  @override
  Widget build(BuildContext context) {
    final sig = c.sig, tug = c.tug, mit = c.mit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Card(
          color: const Color(0xF9DD9A00),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(children: const [
                  Expanded(child: Text('Level')),
                  Expanded(child: Text('Game')),
                  Expanded(child: Text('High Score')),
                  Expanded(child: Text('Last Score')),
                ]),
                const Divider(
                  color: const Color(0xAD572100),
                ),
                Row(children: [
                  Expanded(child: Text(sig.badge.label)),
                  const Expanded(child: Text('Siglulung')),
                  Expanded(child: Text(high[0])),
                  Expanded(child: Text(last[0])),
                ]),
                Row(children: [
                  Expanded(child: Text(tug.badge.label)),
                  const Expanded(child: Text('Tugak Catching')),
                  Expanded(child: Text(high[1])),
                  Expanded(child: Text(last[1])),
                ]),
                Row(children: [
                  Expanded(child: Text(mit.badge.label)),
                  const Expanded(child: Text('Mitutuglung')),
                  Expanded(child: Text(high[2])),
                  Expanded(child: Text(last[2])),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
