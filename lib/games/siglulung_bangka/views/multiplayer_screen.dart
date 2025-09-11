import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/game_service.dart';
import '../../shared/widgets/base_multiplayer_screen.dart';
import './game_screen.dart';

class SiglulungMultiplayerAdapter {
  final String matchId;
  final _sb = Supabase.instance.client;

  int _lastWpm = 0;
  double _lastAcc = 0;

  SiglulungMultiplayerAdapter(this.matchId);

  Future<void> updateStats({required int wpm, required double accuracy}) async {
    _lastWpm = wpm;
    _lastAcc = accuracy;
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _sb.from('multiplayer_live').update({
      'wpm': wpm,
      'accuracy': accuracy,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).match({'match_id': matchId, 'user_id': uid});
  }

  Future<void> finish() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    final difficulty =
        await GameService().getUserDifficulty('siglulung_bangka');

    await _sb.from('multiplayer_results').insert({
      'match_id': matchId,
      'user_id': uid,
      'score': _lastWpm,
      'accuracy': _lastAcc,
      'secondary_score': _lastWpm,
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
      gameType: 'siglulung_bangka',
      accuracy: _lastAcc.round(),
      secondaryScore: _lastWpm,
      score: _lastWpm,
      difficulty: difficulty,
    );
  }
}

class SiglulungBangkaMultiplayerScreen extends StatefulWidget {
  final String matchId;
  const SiglulungBangkaMultiplayerScreen({super.key, required this.matchId});

  @override
  State<SiglulungBangkaMultiplayerScreen> createState() =>
      _SiglulungBangkaMultiplayerScreenState();
}

class _SiglulungBangkaMultiplayerScreenState
    extends State<SiglulungBangkaMultiplayerScreen> {
  late final SiglulungMultiplayerAdapter _adapter;
  final _sb = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _adapter = SiglulungMultiplayerAdapter(widget.matchId);
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
      showWpm: true,
      showAccuracy: true,
      child: BangkaGameScreen(
        multiplayerMatchId: widget.matchId,
        multiplayerAdapter: _adapter,
      ),
    );
  }
}
