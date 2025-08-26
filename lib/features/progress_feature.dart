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

//stats
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
  static const wpm = [30, 50, 70];
  static const sigAccuracy = [85, 92, 97];

  static const fluency = [10, 20, 35];
  static const tugAccuracy = [80, 90, 95];

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

class BadgePill extends StatelessWidget {
  final String text;
  const BadgePill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (text) {
      'Expert' => Colors.lightGreenAccent,
      'Intermediate' => Colors.yellowAccent,
      'Beginner' => Colors.orangeAccent,
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

class ProgressRow extends TableRow {
  ProgressRow({
    required String col1,
    required String col2,
    required String col3,
    required String col4,
  }) : super(children: [
          Padding(padding: const EdgeInsets.all(12), child: Text(col1)),
          Padding(padding: const EdgeInsets.all(12), child: Text(col2)),
          Padding(padding: const EdgeInsets.all(12), child: Text(col3)),
          Padding(padding: const EdgeInsets.all(12), child: Text(col4)),
        ]);
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.5),
          verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.5),
        ),
        children: [
          //headers
          const TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("LEVEL",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("SKILL",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("HIGH SCORE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("XP TO LEVEL UP",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),

          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(p.metricA.label, textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(rowLabels[0], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(high[0], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(xp[0], textAlign: TextAlign.center),
            ),
          ]),

          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(p.metricB.label, textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(rowLabels[1], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(high[1], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(xp[1], textAlign: TextAlign.center),
            ),
          ]),
        ],
      ),
    );
  }
}

class MacroProgressTable extends StatelessWidget {
  final ProgressController c;
  final List<String> high;
  final List<String> last;

  const MacroProgressTable({
    super.key,
    required this.c,
    required this.high,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final sig = c.sig, tug = c.tug, mit = c.mit;

    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.5),
          verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.5),
        ),
        children: [
          //headers
          const TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("LEVEL",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("GAME",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("HIGH SCORE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("LAST SCORE",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),

          //siglulung
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(sig.badge.label, textAlign: TextAlign.center),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Siglulung", textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(high[0], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(last[0], textAlign: TextAlign.center),
            ),
          ]),

          //tugak
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(tug.badge.label, textAlign: TextAlign.center),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Tugak Catching", textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(high[1], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(last[1], textAlign: TextAlign.center),
            ),
          ]),

          //mitutuglung
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(mit.badge.label, textAlign: TextAlign.center),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Mitutuglung", textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(high[2], textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(last[2], textAlign: TextAlign.center),
            ),
          ]),
        ],
      ),
    );
  }
}
