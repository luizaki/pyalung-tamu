import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class MultiplayerService {
  final supabase = Supabase.instance.client;

  Future<void> ensureLiveRow(String matchId) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('multiplayer_live').upsert(
      {'match_id': matchId, 'user_id': uid},
      onConflict: 'match_id,user_id',
    );
  }

  Future<String> quickMatch(String gameType,
      {Duration timeout = const Duration(seconds: 45)}) async {
    final uid = supabase.auth.currentUser!.id;

    final rpcRes = await supabase.rpc('claim_or_create_match', params: {
      'p_game_type': gameType,
    });

    final matchId = rpcRes as String;

    final start = DateTime.now();
    while (DateTime.now().difference(start) < timeout) {
      final row = await supabase
          .from('multiplayer_matches')
          .select('status, player1_id, player2_id')
          .eq('match_id', matchId)
          .single();

      final status = row['status'] as String?;
      final p2 = row['player2_id'];

      if (status == 'active' && p2 != null) {
        await ensureLiveRow(matchId);
        return matchId;
      }
      await Future.delayed(const Duration(milliseconds: 700));
    }

    await supabase
        .from('multiplayer_matches')
        .update({'status': 'abandoned'}).eq('match_id', matchId);
    throw Exception('No opponent found in time');
  }

  Future<void> abandonMatch(String matchId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase
        .from('multiplayer_matches')
        .update({'status': 'abandoned'}).eq('match_id', matchId);
  }
}
