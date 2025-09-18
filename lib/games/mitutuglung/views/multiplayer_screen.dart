import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/game_service.dart';
import '../../../services/multiplayer_service.dart';
import '../../shared/widgets/base_multiplayer_screen.dart';
import './game_screen.dart';

class MultiplayerMitutuglungAdapter {
  final String matchId;
  final _sb = Supabase.instance.client;

  int _pairs = 0;
  int _attempts = 0;
  int _hits = 0;

  MultiplayerMitutuglungAdapter(this.matchId);

  double get accuracy => _attempts == 0 ? 0 : (_hits * 100.0 / _attempts);

  double _clampPct(num v) => v.toDouble().clamp(0.0, 100.0);

  Future<void> updateStats({
    required int pairs,
    required double accuracy,
  }) async {
    _pairs = pairs;
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    await _sb.from('multiplayer_live').upsert(
      {
        'match_id': matchId,
        'user_id': uid,
        'pairs': pairs,
        'accuracy': _clampPct(accuracy),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'match_id,user_id',
    );
  }

  Future<void> recordAttempt({required bool correct}) async {
    _attempts += 1;
    if (correct) {
      _hits += 1;
      _pairs += 1;
    }
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    await _sb.from('multiplayer_live').upsert(
      {
        'match_id': matchId,
        'user_id': uid,
        'pairs': _pairs,
        'accuracy': _clampPct(accuracy),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'match_id,user_id',
    );
  }

  Future<void> finish() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    await _sb.from('multiplayer_live').upsert(
      {
        'match_id': matchId,
        'user_id': uid,
        'pairs': _pairs,
        'accuracy': _clampPct(accuracy),
        'is_ready': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'match_id,user_id',
    );
  }
}

class MitutuglungMultiplayerScreen extends StatefulWidget {
  final String matchId;
  const MitutuglungMultiplayerScreen({super.key, required this.matchId});

  @override
  State<MitutuglungMultiplayerScreen> createState() =>
      _MitutuglugMultiplayerScreenState();
}

class _MitutuglugMultiplayerScreenState
    extends State<MitutuglungMultiplayerScreen> {
  late final MultiplayerMitutuglungAdapter _adapter;
  final _sb = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _adapter = MultiplayerMitutuglungAdapter(widget.matchId);
    _ensureLiveRow();
  }

  Future<void> _ensureLiveRow() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb.from('multiplayer_live').upsert(
      {'match_id': widget.matchId, 'user_id': uid},
      onConflict: 'match_id,user_id',
    );
  }

  Future<void> _rematch() async {
    final newId = await MultiplayerService().quickMatch('mitutuglung');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MitutuglungMultiplayerScreen(
          key: ValueKey('mp-$newId'),
          matchId: newId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseMultiplayerScreen(
      matchId: widget.matchId,
      showPairs: true,
      showAccuracy: true,
      child: MitutuglungGameScreen(
        key: ValueKey('game-${widget.matchId}'),
        multiplayerMatchId: widget.matchId,
        multiplayerAdapter: _adapter,
        onPlayAgain: _rematch,
      ),
    );
  }
}
