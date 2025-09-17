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

  int myWpm = 0, myFrogs = 0, myPairs = 0;
  double myAcc = 0;

  List<_OpponentStats> opponents = [];

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
          .select('status, player1_id, player2_id, player3_id')
          .eq('match_id', widget.matchId)
          .single();

      final p1 = match['player1_id'] as String?;
      final p2 = match['player2_id'] as String?;
      final p3 = match['player3_id'] as String?;
      final status = match['status'] as String? ?? 'waiting';

      final rows = await supabase
          .from('multiplayer_live')
          .select('user_id, wpm, frogs, pairs, accuracy')
          .eq('match_id', widget.matchId);

      int _myWpm = 0, _myFrogs = 0, _myPairs = 0;
      double _myAcc = 0;
      final oppMap = <String, _OpponentStats>{};

      for (final r in (rows as List)) {
        final rowUid = r['user_id'] as String;
        final wpm = r['wpm'] as int? ?? 0;
        final frogs = r['frogs'] as int? ?? 0;
        final pairs = r['pairs'] as int? ?? 0;
        final acc = (r['accuracy'] as num?)?.toDouble() ?? 0.0;

        if (rowUid == uid) {
          _myWpm = wpm;
          _myFrogs = frogs;
          _myPairs = pairs;
          _myAcc = acc;
        } else {
          oppMap[rowUid] = _OpponentStats(
            userId: rowUid,
            name: 'Opponent',
            wpm: wpm,
            frogs: frogs,
            pairs: pairs,
            acc: acc,
          );
        }
      }

      if (oppMap.isNotEmpty) {
        final oppIds = oppMap.keys.toList();
        final userRows = await supabase
            .from('users')
            .select('auth_id, user_name')
            .inFilter('auth_id', oppIds);

        if (userRows is List) {
          for (final u in userRows) {
            final aid = u['auth_id'] as String?;
            final uname = u['user_name'] as String?;
            if (aid != null && oppMap.containsKey(aid)) {
              oppMap[aid] = oppMap[aid]!.copyWith(
                name: uname ?? 'Opponent',
              );
            }
          }
        }
      }

      final oppList = oppMap.values.toList()
        ..sort((a, b) => a.userId.compareTo(b.userId));
      final trimmedOpponents =
          oppList.length > 2 ? oppList.sublist(0, 2) : oppList;

      final threePresent = (p1 != null && p2 != null && p3 != null);
      final newStatus =
          (status == 'active' || threePresent) ? 'active' : 'waiting';

      if (!mounted) return;
      setState(() {
        _status = newStatus;
        myWpm = _myWpm;
        myFrogs = _myFrogs;
        myPairs = _myPairs;
        myAcc = _myAcc;
        opponents = trimmedOpponents;
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
                child: const IgnorePointer(
                  child: _BannerPill(text: 'Waiting for players…'),
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
                        me: _PlayerCol(
                          label: 'You',
                          wpm: myWpm.toDouble(),
                          frogs: myFrogs.toDouble(),
                          pairs: myPairs.toDouble(),
                          acc: myAcc,
                        ),
                        opponents: opponents,
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

class _PlayerCol {
  final String label;
  final double wpm;
  final double frogs;
  final double pairs;
  final double acc;
  const _PlayerCol({
    required this.label,
    required this.wpm,
    required this.frogs,
    required this.pairs,
    required this.acc,
  });
}

class _OpponentStats {
  final String userId;
  final String name;
  final int wpm;
  final int frogs;
  final int pairs;
  final double acc;

  const _OpponentStats({
    required this.userId,
    required this.name,
    required this.wpm,
    required this.frogs,
    required this.pairs,
    required this.acc,
  });

  _OpponentStats copyWith({String? name}) => _OpponentStats(
        userId: userId,
        name: name ?? this.name,
        wpm: wpm,
        frogs: frogs,
        pairs: pairs,
        acc: acc,
      );
}

class _ScoreBadge extends StatelessWidget {
  final bool showWpm, showFrogs, showPairs, showAccuracy;
  final _PlayerCol me;
  final List<_OpponentStats> opponents;

  const _ScoreBadge({
    required this.showWpm,
    required this.showFrogs,
    required this.showPairs,
    required this.showAccuracy,
    required this.me,
    required this.opponents,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];
    if (showWpm) labels.add('WPM');
    if (showFrogs) labels.add('Frogs');
    if (showPairs) labels.add('Pairs');
    if (showAccuracy) labels.add('Acc');
    if (labels.isEmpty) return const SizedBox.shrink();

    final oppA = opponents.isNotEmpty ? opponents[0] : null;
    final oppB = opponents.length > 1 ? opponents[1] : null;

    final headerNames = [
      'You',
      if (oppA != null) _short(oppA.name),
      if (oppB != null) _short(oppB.name),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Material(
        elevation: 6,
        color: const Color(0xF9DD9A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF5A3A00), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Score',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...headerNames.map((n) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          n,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 4),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: const IntrinsicColumnWidth(),
                  1: const FixedColumnWidth(46),
                  if (oppA != null) 2: const FixedColumnWidth(46),
                  if (oppB != null) 3: const FixedColumnWidth(46),
                },
                children: labels.map((label) {
                  final meVal = _metricValue(label, me);
                  final aVal =
                      oppA != null ? _metricValue(label, _fromOpp(oppA)) : null;
                  final bVal =
                      oppB != null ? _metricValue(label, _fromOpp(oppB)) : null;

                  bool meLead = true;
                  if (aVal != null) meLead = meLead && (meVal >= aVal);
                  if (bVal != null) meLead = meLead && (meVal >= bVal);

                  bool aLead = aVal != null &&
                      aVal >= meVal &&
                      (bVal == null || aVal >= bVal);
                  bool bLead = bVal != null &&
                      bVal >= meVal &&
                      (aVal == null || bVal >= aVal);

                  return TableRow(children: [
                    _LabelCell(label),
                    _ValueCell(value: _fmt(label, meVal), leading: meLead),
                    if (aVal != null)
                      _ValueCell(value: _fmt(label, aVal), leading: aLead),
                    if (bVal != null)
                      _ValueCell(value: _fmt(label, bVal), leading: bLead),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _PlayerCol _fromOpp(_OpponentStats o) => _PlayerCol(
        label: o.name,
        wpm: o.wpm.toDouble(),
        frogs: o.frogs.toDouble(),
        pairs: o.pairs.toDouble(),
        acc: o.acc,
      );

  static double _metricValue(String label, _PlayerCol p) {
    switch (label) {
      case 'WPM':
        return p.wpm;
      case 'Frogs':
        return p.frogs;
      case 'Pairs':
        return p.pairs;
      case 'Acc':
        return p.acc;
      default:
        return 0;
    }
  }

  static String _fmt(String label, double v) {
    if (label == 'Acc') return '${v.round()}%';
    return (v == v.roundToDouble())
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
  }

  static String _short(String name) {
    if (name.isEmpty) return 'Opp';
    return name.length <= 8 ? name : '${name.substring(0, 7)}…';
  }
}

class _LabelCell extends StatelessWidget {
  final String text;
  const _LabelCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
    final base = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    final chipColor =
        leading ? const Color(0xFF2BB495) : const Color(0xFFE6D4A3);
    final chipText = leading ? Colors.white : const Color(0xFF3A2A1A);
    final border = BorderSide(
      color: const Color(0xFF5A3A00).withOpacity(0.65),
      width: 1.0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
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
