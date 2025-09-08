import 'package:flutter/material.dart';

// ================== LEVEL SYSTEM ==================
enum Level { none, beginner, intermediate, advanced }

extension LevelX on Level {
  int get v => index;
  String get label => switch (this) {
        Level.none => 'N/A',
        Level.beginner => 'Beginner',
        Level.intermediate => 'Intermediate',
        Level.advanced => 'Advanced',
      };
}

// ================== STATS ==================
class SiglulungStats {
  final double wpm, latestWpm;
  final double accuracy, latestAccuracy;

  const SiglulungStats({
    required this.wpm,
    required this.accuracy,
    required this.latestWpm,
    required this.latestAccuracy,
  });
}

class TugakStats {
  final int fluency, latestFluency;
  final double accuracy, latestAccuracy;
  const TugakStats({
    required this.fluency,
    required this.accuracy,
    required this.latestFluency,
    required this.latestAccuracy,
  });
}

class MitutuglungStats {
  final int perfectPairs, latestPerfectPairs;
  final double accuracy, latestAccuracy;
  const MitutuglungStats({
    required this.perfectPairs,
    required this.accuracy,
    required this.latestPerfectPairs,
    required this.latestAccuracy,
  });
}

// ================== PROGRESS ==================
class GameProgress {
  final Level metricA, metricB, badge;
  final double progA, progB;
  const GameProgress(
      this.metricA, this.metricB, this.badge, this.progA, this.progB);
}

class Thresholds {
  static const wpm = [30, 50, 70];
  static const sigAccuracy = [85, 92, 97];

  static const fluency = [5, 10, 15];
  static const tugAccuracy = [80, 90, 95];

  static const perfectPairs = [1, 4, 6];
  static const mitAccuracy = [30, 50, 70];
}

Level _inc(num v, List<num> t) {
  if (v >= t[2]) return Level.advanced;
  if (v >= t[1]) return Level.intermediate;
  if (v >= t[0]) return Level.beginner;
  return Level.none;
}

double _pUp(num v, List<num> t) {
  if (v < t[0]) return (v / t[0]).clamp(0, 1).toDouble();
  if (v < t[1]) return ((v - t[0]) / (t[1] - t[0])).clamp(0, 1).toDouble();
  if (v < t[2]) return ((v - t[1]) / (t[2] - t[1])).clamp(0, 1).toDouble();
  return 1;
}

// ================== EVALUATORS ==================
GameProgress evalSiglulung(SiglulungStats s) {
  final a = _inc(s.wpm, Thresholds.wpm);
  final b = _inc(s.accuracy, Thresholds.sigAccuracy);

  final avg = ((a.v + b.v) / 2).round();
  final badge = Level.values[avg];

  return GameProgress(
    a,
    b,
    badge,
    _pUp(s.wpm, Thresholds.wpm),
    _pUp(s.accuracy, Thresholds.sigAccuracy),
  );
}

GameProgress evalTugak(TugakStats s) {
  final a = _inc(s.fluency, Thresholds.fluency);
  final b = _inc(s.accuracy, Thresholds.tugAccuracy);

  final avg = ((a.v + b.v) / 2).round();
  final badge = Level.values[avg];

  return GameProgress(
    a,
    b,
    badge,
    _pUp(s.fluency, Thresholds.fluency),
    _pUp(s.accuracy, Thresholds.tugAccuracy),
  );
}

GameProgress evalMitutuglung(MitutuglungStats s) {
  final a = _inc(s.perfectPairs, Thresholds.perfectPairs);
  final b = _inc(s.accuracy, Thresholds.mitAccuracy);

  final avg = ((a.v + b.v) / 2).round();
  final badge = Level.values[avg];

  return GameProgress(
    a,
    b,
    badge,
    _pUp(s.perfectPairs, Thresholds.perfectPairs),
    _pUp(s.accuracy, Thresholds.mitAccuracy),
  );
}

Level evalMacro(GameProgress g1, GameProgress g2, GameProgress g3) {
  final avg = (g1.badge.v + g2.badge.v + g3.badge.v) / 3.0;

  if (avg >= 2.5) return Level.advanced;
  if (avg >= 1.5) return Level.intermediate;
  if (avg >= 0.5) return Level.beginner;

  return Level.none;
}

// ================== CONTROLLER ==================
class ProgressController {
  SiglulungStats? _sig;
  TugakStats? _tug;
  MitutuglungStats? _mit;

  void setSiglulung(SiglulungStats? s) => _sig = s;
  void setTugak(TugakStats? s) => _tug = s;
  void setMitutuglung(MitutuglungStats? s) => _mit = s;

  GameProgress get sig => evalSiglulung(_sig ??
      const SiglulungStats(
          wpm: 0, accuracy: 0, latestWpm: 0, latestAccuracy: 0));
  GameProgress get tug => evalTugak(_tug ??
      const TugakStats(
          fluency: 0, accuracy: 0, latestFluency: 0, latestAccuracy: 0));
  GameProgress get mit => evalMitutuglung(_mit ??
      const MitutuglungStats(
          perfectPairs: 0,
          accuracy: 0,
          latestPerfectPairs: 0,
          latestAccuracy: 0));

  Level get macro => evalMacro(sig, tug, mit);
}

// ================== UI WIDGETS ==================
class BadgePill extends StatelessWidget {
  final String text;
  const BadgePill(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final normalized = text[0].toUpperCase() + text.substring(1).toLowerCase();

    final color = switch (normalized) {
      'Advanced' => Colors.lightGreenAccent,
      'Intermediate' => Colors.yellowAccent,
      'Beginner' => Colors.orangeAccent,
      _ => Theme.of(context).disabledColor.withAlpha(80),
    };

    final padH = (w * 0.008).clamp(8.0, 16.0);
    final padV = (w * 0.004).clamp(4.0, 10.0);
    final fs = (w * 0.014).clamp(10.0, 18.0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black54, width: 1.2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          normalized,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: fs),
        ),
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
    final w = MediaQuery.of(context).size.width;
    final cellFs = (w * 0.012).clamp(10.0, 16.0);
    final headFs = (w * 0.014).clamp(11.0, 18.0);
    final cellPad = EdgeInsets.symmetric(
      horizontal: (w * 0.008).clamp(6.0, 12.0),
      vertical: (w * 0.006).clamp(4.0, 10.0),
    );
    final cardPad = EdgeInsets.all((w * 0.010).clamp(8.0, 16.0));

    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Padding(
        padding: cardPad,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(2),
          },
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
            verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
          ),
          children: [
            TableRow(children: [
              Padding(
                padding: cellPad,
                child: Text("LEVEL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text("SKILL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text("HIGH SCORE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text("XP TO LEVEL UP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: headFs)),
              ),
            ]),
            TableRow(children: [
              Padding(
                padding: cellPad,
                child: Text(p.metricA.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(rowLabels[0],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(high[0],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(xp[0],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
            ]),
            TableRow(children: [
              Padding(
                padding: cellPad,
                child: Text(p.metricB.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(rowLabels[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(high[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
              Padding(
                padding: cellPad,
                child: Text(xp[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cellFs)),
              ),
            ]),
          ],
        ),
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
    final w = MediaQuery.of(context).size.width;
    final cellFs = (w * 0.012).clamp(10.0, 16.0);
    final headFs = (w * 0.014).clamp(11.0, 18.0);
    final cellPad = EdgeInsets.symmetric(
      horizontal: (w * 0.008).clamp(6.0, 12.0),
      vertical: (w * 0.006).clamp(4.0, 10.0),
    );
    final cardMarginV = (w * 0.006).clamp(6.0, 12.0);
    final sig = c.sig, tug = c.tug, mit = c.mit;

    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: cardMarginV),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.8),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
          verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
        ),
        children: [
          // header
          TableRow(children: [
            _headerCell("LEVEL", headFs, cellPad),
            _headerCell("GAME", headFs, cellPad),
            _headerCell("HIGH SCORE", headFs, cellPad),
            _headerCell("LAST SCORE", headFs, cellPad),
          ]),
          // Siglulung row
          TableRow(children: [
            Padding(
              padding: cellPad,
              child: Center(child: BadgePill(sig.badge.label)),
            ),
            _plainCell("Siglulung Bangka", cellFs, cellPad),
            _plainCell("${high[0]} WPM", cellFs, cellPad),
            _plainCell("${last[0]} WPM", cellFs, cellPad),
          ]),
          // Tugak row
          TableRow(children: [
            Padding(
              padding: cellPad,
              child: Center(child: BadgePill(tug.badge.label)),
            ),
            _plainCell("Tugak Catching", cellFs, cellPad),
            _plainCell("${high[1]} frogs", cellFs, cellPad),
            _plainCell("${last[1]} frogs", cellFs, cellPad),
          ]),
          // Mitutuglung row
          TableRow(children: [
            Padding(
              padding: cellPad,
              child: Center(child: BadgePill(mit.badge.label)),
            ),
            _plainCell("Mitutuglung", cellFs, cellPad),
            _plainCell("${high[2]} pairs", cellFs, cellPad),
            _plainCell("${last[2]} pairs", cellFs, cellPad),
          ]),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double fs, EdgeInsets pad) => Padding(
        padding: pad,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: fs)),
      );

  Widget _plainCell(String text, double fs, EdgeInsets pad) => Padding(
        padding: pad,
        child: Text(text,
            textAlign: TextAlign.center, style: TextStyle(fontSize: fs)),
      );
}

// ==================== EXTENSIONS ====================
extension ProgressControllerXP on ProgressController {
  // Siglulung
  String nextSigWpm() {
    final v = _sig?.wpm ?? 0;
    for (final t in Thresholds.wpm) {
      if (v < t) return "reach ${t.toInt()} WPM";
    }
    return "Maxed";
  }

  String nextSigAcc() {
    final v = _sig?.accuracy ?? 0;
    for (final t in Thresholds.sigAccuracy) {
      if (v < t) return "Reach ${t.toInt()}%";
    }
    return "Maxed";
  }

  // Tugak
  String nextTugFluency() {
    final v = _tug?.fluency ?? 0;
    for (final t in Thresholds.fluency) {
      if (v < t) return "${t - v} frogs left";
    }
    return "Maxed";
  }

  String nextTugAcc() {
    final v = _tug?.accuracy ?? 0;
    for (final t in Thresholds.tugAccuracy) {
      if (v < t) return "Reach ${t.toInt()}%";
    }
    return "Maxed";
  }

  // Mitutuglung
  String nextMitPairs() {
    final v = _mit?.perfectPairs ?? 0;
    for (final t in Thresholds.perfectPairs) {
      if (v < t) return "Reach $t pairs";
    }
    return "Maxed";
  }

  String nextMitAcc() {
    final v = _mit?.accuracy ?? 0;
    for (final t in Thresholds.mitAccuracy) {
      if (v < t) return "Reach ${t.toInt()}%";
    }
    return "Maxed";
  }
}
