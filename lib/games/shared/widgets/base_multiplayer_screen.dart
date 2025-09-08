import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaseMultiplayerScreen extends StatefulWidget {
  final String matchId;
  final Widget child;

  final bool showWpm;
  final bool showFrogs;
  final bool showPairs;
  final bool showAccuracy;

  const BaseMultiplayerScreen({
    super.key,
    required this.matchId,
    required this.child,
    this.showWpm = false,
    this.showFrogs = false,
    this.showPairs = false,
    this.showAccuracy = false,
  });

  @override
  State<BaseMultiplayerScreen> createState() =>
      BaseMultiplayerScreen_BaseMultiplayerScreenState();
}

class BaseMultiplayerScreen_BaseMultiplayerScreenState
    extends State<BaseMultiplayerScreen> {
  final supabase = Supabase.instance.client;

  int myWpm = 0, oppWpm = 0;
  int myFrogs = 0, oppFrogs = 0;
  int myPairs = 0, oppPairs = 0;
  double myAcc = 0, oppAcc = 0;

  String _status = 'waiting'; // waiting | active | finished | abandoned
  Timer? _timer;

  bool get _hudVisible => _status == 'active';

  @override
  void initState() {
    super.initState();
    _ensureLiveRow().then((_) => _startPolling());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _ensureLiveRow() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase.from('multiplayer_live').upsert(
      {'match_id': widget.matchId, 'user_id': uid},
      onConflict: 'match_id,user_id',
    );
  }

  void _startPolling() {
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final match = await supabase
          .from('multiplayer_matches')
          .select('status, player1_id, player2_id')
          .eq('match_id', widget.matchId)
          .single();

      final rows = await supabase
          .from('multiplayer_live')
          .select('user_id, wpm, frogs, pairs, accuracy')
          .eq('match_id', widget.matchId);

      int _myWpm = 0, _oppWpm = 0;
      int _myFrogs = 0, _oppFrogs = 0;
      int _myPairs = 0, _oppPairs = 0;
      double _myAcc = 0, _oppAcc = 0;

      for (final r in (rows as List)) {
        final isMe = r['user_id'] == uid;
        final wpm = r['wpm'] as int? ?? 0;
        final frogs = r['frogs'] as int? ?? 0;
        final pairs = r['pairs'] as int? ?? 0;
        final acc = (r['accuracy'] as num?)?.toDouble() ?? 0.0;

        if (isMe) {
          _myWpm = wpm;
          _myFrogs = frogs;
          _myPairs = pairs;
          _myAcc = acc;
        } else {
          _oppWpm = wpm;
          _oppFrogs = frogs;
          _oppPairs = pairs;
          _oppAcc = acc;
        }
      }

      if (!mounted) return;
      setState(() {
        _status = (match['status'] as String?) ?? 'waiting';
        myWpm = _myWpm;
        oppWpm = _oppWpm;
        myFrogs = _myFrogs;
        oppFrogs = _oppFrogs;
        myPairs = _myPairs;
        oppPairs = _oppPairs;
        myAcc = _myAcc;
        oppAcc = _oppAcc;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_status == 'waiting')
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: IgnorePointer(
                  child: _BannerPill(text: 'Waiting for opponent…'),
                ),
              ),
            ),
          ),
        SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _hudVisible
                ? Align(
                    key: const ValueKey('hud'),
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: _ScoreBadge(
                        showWpm: widget.showWpm,
                        showFrogs: widget.showFrogs,
                        showPairs: widget.showPairs,
                        showAccuracy: widget.showAccuracy,
                        myWpm: myWpm,
                        oppWpm: oppWpm,
                        myFrogs: myFrogs,
                        oppFrogs: oppFrogs,
                        myPairs: myPairs,
                        oppPairs: oppPairs,
                        myAcc: myAcc,
                        oppAcc: oppAcc,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _BannerPill extends StatelessWidget {
  final String text;
  const _BannerPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: const Color(0xF9DD9A00),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final bool showWpm, showFrogs, showPairs, showAccuracy;
  final int myWpm, oppWpm, myFrogs, oppFrogs, myPairs, oppPairs;
  final double myAcc, oppAcc;

  const _ScoreBadge({
    required this.showWpm,
    required this.showFrogs,
    required this.showPairs,
    required this.showAccuracy,
    required this.myWpm,
    required this.oppWpm,
    required this.myFrogs,
    required this.oppFrogs,
    required this.myPairs,
    required this.oppPairs,
    required this.myAcc,
    required this.oppAcc,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <_MetricRow>[];
    if (showWpm)
      rows.add(_MetricRow('Pairs', myWpm.toDouble(), oppWpm.toDouble(),
          higherIsBetter: true, isPercent: false));
    if (showFrogs)
      rows.add(_MetricRow('Frogs', myFrogs.toDouble(), oppFrogs.toDouble(),
          higherIsBetter: true, isPercent: false));
    if (showPairs)
      rows.add(_MetricRow('Pairs', myPairs.toDouble(), oppPairs.toDouble(),
          higherIsBetter: true, isPercent: false));
    if (showAccuracy)
      rows.add(_MetricRow('Acc', myAcc, oppAcc,
          higherIsBetter: true, isPercent: true));
    if (rows.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Material(
        elevation: 6,
        color: const Color(0xF9DD9A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF5A3A00), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Scoreboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('You',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.black)),
                  SizedBox(width: 14),
                  Text('Opp',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 6),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FixedColumnWidth(54),
                  2: FixedColumnWidth(54),
                },
                children: rows
                    .map((r) => TableRow(children: [
                          _LabelCell(r.label),
                          _ValueCell(value: r.formattedMe, leading: r.meLeads),
                          _ValueCell(
                              value: r.formattedOpp, leading: r.oppLeads),
                        ]))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  final String text;
  const _LabelCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String value;
  final bool leading;

  const _ValueCell({required this.value, required this.leading});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final chipColor =
        leading ? const Color(0xFF2BB495) : const Color(0xFFE6D4A3);
    final chipText = leading ? Colors.white : const Color(0xFF3A2A1A);
    final border = BorderSide(
        color: const Color(0xFF5A3A00).withOpacity(0.65), width: 1.2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.fromBorderSide(border),
        ),
        child: Text(value,
            textAlign: TextAlign.center, style: base.copyWith(color: chipText)),
      ),
    );
  }
}

class _MetricRow {
  final String label;
  final double me;
  final double opp;
  final bool higherIsBetter;
  final bool isPercent;

  _MetricRow(this.label, this.me, this.opp,
      {required this.higherIsBetter, required this.isPercent});

  bool get meLeads => higherIsBetter ? me > opp : me < opp;
  bool get oppLeads => higherIsBetter ? opp > me : opp < me;

  String get formattedMe => isPercent ? '${me.round()}%' : _trim(me);
  String get formattedOpp => isPercent ? '${opp.round()}%' : _trim(opp);

  String _trim(double v) =>
      (v == v.roundToDouble()) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
