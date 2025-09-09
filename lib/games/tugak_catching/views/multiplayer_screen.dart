import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/game_service.dart';
import '../../shared/widgets/base_multiplayer_screen.dart';
import './game_screen.dart';

class TugakMultiplayerAdapter {
  final String matchId;
  final _sb = Supabase.instance.client;

  int _lastFrogs = 0;
  double _lastAcc = 0;

  TugakMultiplayerAdapter(this.matchId);

  Future<void> updateStats(
      {required int frogs, required double accuracy}) async {
    _lastFrogs = frogs;
    _lastAcc = accuracy;
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb.from('multiplayer_live').update({
      'frogs': frogs,
      'accuracy': accuracy,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).match({'match_id': matchId, 'user_id': uid});
  }

  Future<void> finish() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    final difficulty = await GameService().getUserDifficulty('tugak_catching');

    await _sb.from('multiplayer_results').insert({
      'match_id': matchId,
      'user_id': uid,
      'score': _lastFrogs,
      'accuracy': _lastAcc,
      'secondary_score': _lastFrogs,
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
      gameType: 'tugak_catching',
      accuracy: _lastAcc.round(),
      secondaryScore: _lastFrogs,
      score: _lastFrogs,
      difficulty: difficulty,
    );
  }
}

class TugakCatchingMultiplayerScreen extends StatefulWidget {
  final String matchId;
  const TugakCatchingMultiplayerScreen({super.key, required this.matchId});

  @override
  State<TugakCatchingMultiplayerScreen> createState() =>
      _TugakCatchingMultiplayerScreenState();
}

class _TugakCatchingMultiplayerScreenState
    extends State<TugakCatchingMultiplayerScreen> {
  late final TugakMultiplayerAdapter _adapter;
  final _sb = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _adapter = TugakMultiplayerAdapter(widget.matchId);
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
      showFrogs: true,
      showAccuracy: true,
      child: TugakGameScreen(
        multiplayerMatchId: widget.matchId,
        multiplayerAdapter: _adapter,
      ),
    );
  }
}
