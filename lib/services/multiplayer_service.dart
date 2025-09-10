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
    final matchId =
        await supabase.rpc('find_or_create_match_by_skill', params: {
      'p_game_type': gameType,
    }) as String;

    final start = DateTime.now();
    while (DateTime.now().difference(start) < timeout) {
      final row = await supabase
          .from('multiplayer_matches')
          .select('status, player1_id, player2_id')
          .eq('match_id', matchId)
          .maybeSingle();

      if (row != null) {
        final status = row['status'] as String?;
        final p1 = row['player1_id'];
        final p2 = row['player2_id'];

        final bothPlayersReady = p1 != null && p2 != null;

        if (status == 'active' && bothPlayersReady) {
          await ensureLiveRow(matchId);
          return matchId;
        }
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }

    await supabase
        .from('multiplayer_matches')
        .update({'status': 'abandoned'}).eq('match_id', matchId);
    throw Exception('No opponent found in time');
  }

  Future<void> abandonMatch(String matchId) async {
    await supabase
        .from('multiplayer_matches')
        .update({'status': 'abandoned'}).eq('match_id', matchId);
  }
}
