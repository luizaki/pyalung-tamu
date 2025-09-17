import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class MultiplayerService {
  final supabase = Supabase.instance.client;
  static final Map<String, Completer<String>> _inFlightByType = {};

  Future<void> ensureLiveRow(String matchId) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('multiplayer_live').upsert(
      {'match_id': matchId, 'user_id': uid},
      onConflict: 'match_id,user_id',
    );
  }

  Future<String> quickMatch(
    String gameType, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final existingCompleter = _inFlightByType[gameType];
    if (existingCompleter != null) return existingCompleter.future;

    final completer = Completer<String>();
    _inFlightByType[gameType] = completer;

    try {
      final uid = supabase.auth.currentUser!.id;
      final existing = await _findExistingLobby(gameType, uid);
      String matchId;

      if (existing != null) {
        matchId = existing['match_id'] as String;
      } else {
        int? hostBucket;
        double? hostAcc;
        try {
          final prof = await supabase
              .from('users')
              .select('skill_bucket, accuracy')
              .eq('auth_id', uid)
              .maybeSingle();
          if (prof != null) {
            hostBucket = prof['skill_bucket'] as int?;
            hostAcc = (prof['accuracy'] as num?)?.toDouble();
          }
        } catch (_) {}

        final bucketMin = (hostBucket != null) ? hostBucket! - 1 : null;
        final bucketMax = (hostBucket != null) ? hostBucket! + 1 : null;

        final dynamic rpcResult =
            await supabase.rpc('find_or_create_match_by_skill3', params: {
          'p_game_type': gameType,
          'p_bucket_min': bucketMin,
          'p_bucket_max': bucketMax,
          'p_host_bucket': hostBucket,
          'p_host_acc': hostAcc,
        });

        matchId = (rpcResult is String)
            ? rpcResult
            : (rpcResult is Map<String, dynamic> && rpcResult.values.isNotEmpty)
                ? (rpcResult.values.first as String)
                : rpcResult.toString();
      }

      await ensureLiveRow(matchId);

      // wait until all players are active
      final start = DateTime.now();
      while (DateTime.now().difference(start) < timeout) {
        final row = await supabase
            .from('multiplayer_matches')
            .select('status, player1_id, player2_id, player3_id')
            .eq('match_id', matchId)
            .maybeSingle();

        if (row != null) {
          final status = row['status'] as String? ?? 'waiting';
          final p1 = row['player1_id'];
          final p2 = row['player2_id'];
          final p3 = row['player3_id'];
          final threeReady = (p1 != null && p2 != null && p3 != null);

          if (threeReady || status == 'active') {
            completer.complete(matchId);
            return matchId;
          }
        }
        await Future.delayed(const Duration(milliseconds: 700));
      }

      // Timeout
      try {
        await supabase
            .from('multiplayer_matches')
            .update({'status': 'abandoned'}).eq('match_id', matchId);
      } catch (_) {}
      throw Exception('No opponents found in time');
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    } finally {
      _inFlightByType.remove(gameType);
    }
  }

  Future<void> abandonMatch(String matchId) async {
    await supabase
        .from('multiplayer_matches')
        .update({'status': 'abandoned'}).eq('match_id', matchId);
  }

  Future<List<Map<String, dynamic>>> fetchLiveStats(String matchId) async {
    final rows = await supabase
        .from('multiplayer_live')
        .select('user_id, wpm, frogs, pairs, accuracy, is_ready, updated_at')
        .eq('match_id', matchId);

    if (rows is List) {
      return List<Map<String, dynamic>>.from(rows);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchResults(String matchId) async {
    final rows = await supabase
        .from('multiplayer_results')
        .select('user_id, score, accuracy, secondary_score, finished_at')
        .eq('match_id', matchId);

    if (rows is List) {
      return List<Map<String, dynamic>>.from(rows);
    }
    return [];
  }

  /// returns the latest lobby (waiting/active) for the gametype
  Future<Map<String, dynamic>?> _findExistingLobby(
      String gameType, String uid) async {
    try {
      final row = await supabase
          .from('multiplayer_matches')
          .select(
              'match_id, status, player1_id, player2_id, player3_id, created_at')
          .eq('game_type', gameType)
          .inFilter('status', ['waiting', 'active'])
          .or('player1_id.eq.$uid,player2_id.eq.$uid,player3_id.eq.$uid')
          .order('status', ascending: false)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      return row;
    } catch (_) {
      return null;
    }
  }
}
