import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/game_service.dart';
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

  Future<void> recordAttempt({required bool correct}) async {
    _attempts += 1;
    if (correct) {
      _hits += 1;
      _pairs += 1;
    }
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb.from('multiplayer_live').update({
      'pairs': _pairs,
      'accuracy': accuracy,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).match({'match_id': matchId, 'user_id': uid});
  }

  Future<void> finish() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    final difficulty = await GameService().getUserDifficulty('mitutuglung');

    await _sb.from('multiplayer_results').insert({
      'match_id': matchId,
      'user_id': uid,
      'score': _pairs,
      'accuracy': accuracy,
      'secondary_score': _pairs,
    });

    final results = await _sb
        .from('multiplayer_results')
        .select('user_id')
        .eq('match_id', matchId);

    if ((results as List).length >= 2) {
      await _sb
          .from('multiplayer_matches')
          .update({'status': 'finished'})
          .eq('match_id', matchId)
          .neq('status', 'finished');
    }

    await GameService().saveGameScore(
      gameType: 'mitutuglung',
      accuracy: accuracy.round(),
      secondaryScore: _pairs,
      score: _pairs,
      difficulty: difficulty,
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

  @override
  Widget build(BuildContext context) {
    return BaseMultiplayerScreen(
      matchId: widget.matchId,
      showPairs: true,
      showAccuracy: true,
      child: MitutuglungGameScreen(
        multiplayerMatchId: widget.matchId,
        multiplayerAdapter: _adapter,
      ),
    );
  }
}
