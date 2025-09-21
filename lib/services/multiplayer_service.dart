import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchmakingCancelled implements Exception {
  final String message;
  const MatchmakingCancelled([this.message = 'Matchmaking cancelled']);
  @override
  String toString() => message;
}

class _SearchState {
  final Completer<String> completer = Completer<String>();
  bool cancelled = false;
  String? matchId;
  bool abandonHostIfWaiting = true;
}

class MultiplayerService {
  final supabase = Supabase.instance.client;
  static final Map<String, _SearchState> _inFlight = {};

  Future<void> ensureLiveRow(String matchId) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('multiplayer_live').upsert(
      {'match_id': matchId, 'user_id': uid},
      onConflict: 'match_id,user_id',
    );
  }

  Future<void> cancelQuickMatch(String gameType,
      {bool abandonHostIfWaiting = true}) async {
    final s = _inFlight[gameType];
    if (s == null) return;
    s.abandonHostIfWaiting = abandonHostIfWaiting;
    s.cancelled = true;
  }

  Future<String> quickMatch(
    String gameType, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final existing = _inFlight[gameType];
    if (existing != null) return existing.completer.future;

    final s = _SearchState();
    _inFlight[gameType] = s;

    try {
      final uid = supabase.auth.currentUser!.id;
      if (s.cancelled) throw const MatchmakingCancelled();

      await _abandonAnyHostWaiting(gameType, uid);

      final existingRow = await _findExistingLobby(gameType, uid);
      String matchId;

      if (existingRow != null) {
        matchId = existingRow['match_id'] as String;
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
        if (s.cancelled) throw const MatchmakingCancelled();

        final dynamic rpcResult = await supabase.rpc(
          'find_or_create_match_by_skill3',
          params: {
            'p_game_type': gameType,
            'p_bucket_min': bucketMin,
            'p_bucket_max': bucketMax,
            'p_host_bucket': hostBucket,
            'p_host_acc': hostAcc,
            'p_reuse': false,
          },
        );

        matchId = (rpcResult is String)
            ? rpcResult
            : (rpcResult is Map<String, dynamic> && rpcResult.values.isNotEmpty)
                ? (rpcResult.values.first as String)
                : rpcResult.toString();
      }

      s.matchId = matchId;

      if (s.cancelled) await _cleanupOnCancel(gameType, uid, s);
      await ensureLiveRow(matchId);

      final start = DateTime.now();
      while (DateTime.now().difference(start) < timeout) {
        if (s.cancelled) await _cleanupOnCancel(gameType, uid, s);

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
            if (!s.completer.isCompleted) s.completer.complete(matchId);
            return matchId;
          }
        }
        await Future.delayed(const Duration(milliseconds: 700));
      }

      try {
        final row = await supabase
            .from('multiplayer_matches')
            .select('status, player1_id, player2_id, player3_id')
            .eq('match_id', s.matchId!)
            .maybeSingle();

        if (row != null &&
            row['status'] == 'waiting' &&
            row['player1_id'] == uid &&
            row['player2_id'] == null &&
            row['player3_id'] == null) {
          await supabase
              .from('multiplayer_matches')
              .update({'status': 'abandoned'}).eq('match_id', s.matchId!);
        }
      } catch (_) {}

      throw Exception('No opponents found in time');
    } on MatchmakingCancelled catch (e) {
      if (!s.completer.isCompleted) s.completer.completeError(e);
      rethrow;
    } catch (e) {
      if (!s.completer.isCompleted) s.completer.completeError(e);
      rethrow;
    } finally {
      _inFlight.remove(gameType);
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

  Future<void> submitResult({
    required String matchId,
    required int score,
    required double accuracy,
    int? secondaryScore,
  }) async {
    await supabase.rpc('submit_result', params: {
      'p_match_id': matchId,
      'p_score': score,
      'p_accuracy': accuracy,
      'p_secondary_score': secondaryScore,
    });
  }

  Future<void> _abandonAnyHostWaiting(String gameType, String uid) async {
    try {
      await supabase
          .from('multiplayer_matches')
          .update({'status': 'abandoned'})
          .eq('game_type', gameType)
          .eq('player1_id', uid)
          .eq('status', 'waiting')
          .filter('player2_id', 'is', null)
          .filter('player3_id', 'is', null);
    } catch (_) {}
  }

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

  Future<void> _cleanupOnCancel(
      String gameType, String uid, _SearchState s) async {
    if (s.matchId != null && s.abandonHostIfWaiting) {
      try {
        final row = await supabase
            .from('multiplayer_matches')
            .select('status, player1_id, player2_id, player3_id')
            .eq('match_id', s.matchId!)
            .maybeSingle();

        if (row != null &&
            row['status'] == 'waiting' &&
            row['player1_id'] == uid &&
            row['player2_id'] == null &&
            row['player3_id'] == null) {
          await supabase
              .from('multiplayer_matches')
              .update({'status': 'abandoned'}).eq('match_id', s.matchId!);
        }
      } catch (_) {}
    } else {
      await _abandonAnyHostWaiting(gameType, uid);
    }

    if (!s.completer.isCompleted) {
      s.completer.completeError(const MatchmakingCancelled());
    }
    _inFlight.remove(gameType);
    throw const MatchmakingCancelled();
  }
}
