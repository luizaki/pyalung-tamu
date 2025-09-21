import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import './auth_service.dart';
import '/features/progress_feature.dart';

class GameService {
  final _supabase = Supabase.instance.client;

  // =========== SCORES AND DIFFICULTY ===============

  Future<String> getUserDifficulty(String gameType) async {
    try {
      final authService = AuthService();

      if (authService.isGuest) {
        print('🚫 Guest account - not saving score');
        return 'beginner';
      }
      final user = _supabase.auth.currentUser;
      if (user == null) return 'beginner';

      final userRecord = await _supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', user.id)
          .single();

      final progress = await _supabase
          .from('user_game_progress')
          .select('current_difficulty')
          .eq('user_id', userRecord['user_id'])
          .eq('game_type', gameType)
          .maybeSingle();

      return progress?['current_difficulty'] ?? 'beginner';
    } catch (e) {
      print('Error getting user difficulty: $e');
      return 'beginner';
    }
  }

  Future<int> getUserTotalScore() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final authService = AuthService();
      if (authService.isGuest) return 0;

      final userRecord = await _supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', user.id)
          .single();

      final userId = userRecord['user_id'];

      final progressData = await _supabase
          .from('user_game_progress')
          .select('total_score')
          .eq('user_id', userId);

      int totalScore = 0;
      for (var progress in progressData as List) {
        totalScore += (progress['total_score'] as int? ?? 0);
      }

      return totalScore;
    } catch (e) {
      print('Error getting user total score: $e');
      return 0;
    }
  }

  Future<void> saveGameScore({
    required String gameType,
    required int accuracy,
    required int secondaryScore,
    required int score,
    required String difficulty,
  }) async {
    try {
      final authService = AuthService();
      if (authService.isGuest) {
        print('Guest account - not saving score');
        return;
      }
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final userRecord = await _supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', user.id)
          .single();

      final userId = userRecord['user_id'];

      // Save individual score
      await _supabase.from('scores').insert({
        'user_id': userId,
        'game_type': gameType,
        'accuracy': accuracy,
        'secondary_score': secondaryScore,
        'score': score,
        'difficulty_level': difficulty,
      });

      // Update progress
      await _updateUserProgress(
          userId, gameType, score, accuracy, secondaryScore);
    } catch (e) {
      print('Error saving game score: $e');
    }
  }

  Future<void> _updateUserProgress(
      int userId,
      String gameType,
      int score,
      int accuracy,
      int secondaryScore,
      ) async {
    final currentProgress = await _supabase
        .from('user_game_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('game_type', gameType)
        .single();

    final newGamesPlayed = (currentProgress['games_played'] as int? ?? 0) + 1;
    final newTotalScore = (currentProgress['total_score'] as int? ?? 0) + score;
    final currentAvg =
        (currentProgress['average_accuracy'] as num?)?.toDouble() ?? 0.0;
    final newAvgAccuracy =
        ((currentAvg * (currentProgress['games_played'] as int? ?? 0)) +
            accuracy) /
            newGamesPlayed;

    String newDifficulty = _calculateNewDifficulty(
      gameType,
      currentProgress['current_difficulty'] ?? 'beginner',
      secondaryScore,
      newAvgAccuracy,
    );

    await _supabase
        .from('user_game_progress')
        .update({
      'total_score': newTotalScore,
      'games_played': newGamesPlayed,
      'average_accuracy': newAvgAccuracy,
      'best_secondary_score': math.max(
          (currentProgress['best_secondary_score'] as int? ?? 0),
          secondaryScore),
      'current_difficulty': newDifficulty,
      'last_played': DateTime.now().toIso8601String(),
    })
        .eq('user_id', userId)
        .eq('game_type', gameType);
  }

  String _calculateNewDifficulty(String gameType, String currentDifficulty,
      int secondaryScore, double avgAccuracy) {
    if (avgAccuracy < 30) {
      switch (currentDifficulty) {
        case 'advanced':
          return 'intermediate';
        case 'intermediate':
          return 'beginner';
        default:
          return 'beginner';
      }
    } else if (avgAccuracy >= 70) {
      switch (currentDifficulty) {
        case 'beginner':
          return 'intermediate';
        case 'intermediate':
          return 'advanced';
        default:
          return 'advanced';
      }
    } else {
      return currentDifficulty;
    }
  }

  // ============= FETCH STATS =============

  Future<List<dynamic>> _fetchStatData(String id, String difficulty) async {
    try {
      final userRecord = await _supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', id)
          .single();

      final progressData = await _supabase
          .from('user_game_progress')
          .select('best_secondary_score, average_accuracy')
          .eq('user_id', userRecord['user_id'])
          .eq('game_type', difficulty)
          .maybeSingle();

      final latestScore = await _supabase
          .from('scores')
          .select('secondary_score, accuracy')
          .eq('user_id', userRecord['user_id'])
          .eq('game_type', difficulty)
          .order('date_played', ascending: false)
          .limit(1)
          .maybeSingle();

      return [progressData, latestScore];
    } catch (e) {
      print('Error in fetching data: $e');
      rethrow;
    }
  }

  Future<SiglulungStats> fetchSiglulungStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const SiglulungStats(
          wpm: 0, accuracy: 0, latestWpm: 0, latestAccuracy: 0);
    }

    final [progressData, latestScore] =
    await _fetchStatData(user.id, 'siglulung_bangka');

    return SiglulungStats(
      wpm: (progressData?['best_secondary_score'] as num?)?.toDouble() ?? 0,
      accuracy: (progressData?['average_accuracy'] as num?)?.toDouble() ?? 0,
      latestWpm: (latestScore?['secondary_score'] as num?)?.toDouble() ?? 0,
      latestAccuracy: (latestScore?['accuracy'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<TugakStats> fetchTugakStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const TugakStats(
          fluency: 0, accuracy: 0, latestFluency: 0, latestAccuracy: 0);
    }

    final [progressData, latestScore] =
    await _fetchStatData(user.id, 'tugak_catching');

    return TugakStats(
      fluency: progressData?['best_secondary_score'] as int? ?? 0,
      accuracy: (progressData?['average_accuracy'] as num?)?.toDouble() ?? 0,
      latestFluency: latestScore?['secondary_score'] as int? ?? 0,
      latestAccuracy: (latestScore?['accuracy'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<MitutuglungStats> fetchMitutuglungStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const MitutuglungStats(
          perfectPairs: 0,
          accuracy: 0,
          latestPerfectPairs: 0,
          latestAccuracy: 0);
    }

    final [progressData, latestScore] =
    await _fetchStatData(user.id, 'mitutuglung');

    return MitutuglungStats(
      perfectPairs: progressData?['best_secondary_score'] as int? ?? 0,
      accuracy: (progressData?['average_accuracy'] as num?)?.toDouble() ?? 0,
      latestPerfectPairs: latestScore?['secondary_score'] as int? ?? 0,
      latestAccuracy: (latestScore?['accuracy'] as num?)?.toDouble() ?? 0,
    );
  }

  // =========== QUESTIONS FETCHING ===============

  Future<List<WordData>> getWordsByDifficulty(
      {required String difficulty}) async {
    try {
      final response = await _supabase
          .from('words')
          .select('base_form, english_trans')
          .eq('word_difficulty', difficulty);

      return (response as List)
          .map<WordData>((row) => WordData(
        baseForm: row['base_form'] as String,
        englishTrans: row['english_trans'] as String,
      ))
          .toList();
    } catch (e) {
      print('Error fetching random words: $e');
      rethrow;
    }
  }

  Future<List<MitutuglungCardData>> getMitutuglungQuestions(
      {required String difficulty}) async {
    try {
      final response = await _supabase
          .from('mitutuglung_pairs')
          .select(
          'id, kapampangan_word, english_trans, difficulty_level, image_storage_link')
          .eq('difficulty_level', difficulty);

      return (response as List)
          .map<MitutuglungCardData>((row) => MitutuglungCardData(
        id: row['id'].toString(),
        kapampanganWord: row['kapampangan_word'] as String,
        englishTrans: row['english_trans'] as String,
        imagePath: row['image_storage_link'] as String,
      ))
          .toList();
    } catch (e) {
      print('Error fetching Mitutuglung questions: $e');
      rethrow;
    }
  }

  Future<List<TugakQuestionData>> getTugakQuestions(
      {required String difficulty}) async {
    try {
      final response = await _supabase
          .from('sentence_with_tenses')
          .select()
          .eq('word_difficulty', difficulty);

      return (response as List)
          .map<TugakQuestionData>((row) => TugakQuestionData(
        textWithBlank: row['text_with_blank'] as String,
        correctTense: row['correct_tense'] as String,
        sentenceEng: row['sentence_eng'] as String? ?? '',
        pastTense: row['past'] as String,
        presentTense: row['present'] as String,
        futureTense: row['future'] as String,
        engPast: row['eng_past'] as String? ?? '',
        engPresent: row['eng_present'] as String? ?? '',
        engFuture: row['eng_future'] as String? ?? '',
      ))
          .toList();
    } catch (e) {
      print('Error fetching Tugak Catching questions: $e');
      rethrow;
    }
  }

  // ============= LEADERBOARDS =============

  Future<List<LeaderboardEntry>> getOverallLeaderboard({int limit = 10}) async {
    try {
      final response = await _supabase.from('user_game_progress').select('''
      user_id,
      total_score,
      games_played,
      average_accuracy,
      users ( user_name, avatar )
    ''');

      final data = (response as List).cast<Map<String, dynamic>>();

      final Map<int, Map<String, dynamic>> aggregated = {};

      for (final record in data) {
        final userId = record['user_id'] as int;
        final userName = record['users']?['user_name'] ?? 'Anonymous';
        final avatar = record['users']?['avatar'];
        final totalScore = record['total_score'] as int? ?? 0;
        final gamesPlayed = record['games_played'] as int? ?? 0;
        final avgAcc = (record['average_accuracy'] as num?)?.toDouble() ?? 0.0;

        aggregated.putIfAbsent(
            userId,
                () => {
              'user_name': userName,
              'avatar': avatar,
              'total_score': 0,
              'games_played': 0,
              'accuracySum': 0.0,
              'accuracyCount': 0,
            });

        aggregated[userId]!['total_score'] += totalScore;
        aggregated[userId]!['games_played'] += gamesPlayed;

        if (gamesPlayed > 0) {
          aggregated[userId]!['accuracySum'] += avgAcc;
          aggregated[userId]!['accuracyCount'] += 1;
        }
      }

      final leaderboard = aggregated.entries.map((e) {
        final d = e.value;
        final avgAccuracy = (d['accuracyCount'] as int) > 0
            ? (d['accuracySum'] as double) / (d['accuracyCount'] as int)
            : 0.0;

        return LeaderboardEntry(
          rank: 0,
          playerName: d['user_name'] as String,
          avatarUrl: d['avatar'] as String?,
          score: d['total_score'] as int,
          accuracy: avgAccuracy,
          gamesPlayed: d['games_played'] as int,
          isOverallLeaderboard: true,
        );
      }).toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i] = LeaderboardEntry(
          rank: i + 1,
          playerName: leaderboard[i].playerName,
          avatarUrl: leaderboard[i].avatarUrl,
          score: leaderboard[i].score,
          accuracy: leaderboard[i].accuracy,
          gamesPlayed: leaderboard[i].gamesPlayed,
          isOverallLeaderboard: true,
        );
      }

      return (limit > 0) ? leaderboard.take(limit).toList(): leaderboard;
    } catch (e) {
      print('Error fetching overall leaderboard: $e');
      return [];
    }
  }

  Future<List<LeaderboardEntry>> getGameLeaderboard({
    required String gameType,
    int limit = 10,
  }) async {
    try {
      String orderColumn = gameType == 'mitutuglung'
          ? 'average_accuracy'
          : 'best_secondary_score';

      final response = await _supabase
          .from('user_game_progress')
          .select('''
            user_id,
            total_score,
            games_played,
            average_accuracy,
            best_secondary_score,
            users (
              user_name,
              avatar
            )
          ''')
          .eq('game_type', gameType)
          .order(orderColumn, ascending: false);

      final data = (response as List).cast<Map<String, dynamic>>();

      final all = data.asMap().entries.map<LeaderboardEntry>((entry) {
        final i = entry.key;
        final record = entry.value;

        int displayScore;
        if (gameType == 'mitutuglung') {
          displayScore =
              ((record['average_accuracy'] as num?)?.toDouble() ?? 0.0).round();
        } else {
          displayScore = record['best_secondary_score'] as int? ?? 0;
        }

        return LeaderboardEntry(
          rank: i + 1,
          playerName: record['users']?['user_name'] ?? 'Anonymous',
          avatarUrl: record['users']?['avatar'],
          score: displayScore,
          accuracy: (record['average_accuracy'] as num?)?.toDouble() ?? 0.0,
          gamesPlayed: record['games_played'] as int? ?? 0,
          secondaryScore: record['best_secondary_score'] as int? ?? 0,
          isOverallLeaderboard: false,
          gameType: gameType,
        );
      }).toList();

      return (limit > 0) ? all.take(limit).toList() : all;
    } catch (e) {
      print('Error fetching $gameType leaderboard: $e');
      return [];
    }
  }
}

// ============== HELPER CLASSES ==============

class MitutuglungCardData {
  final String id;
  final String kapampanganWord;
  final String englishTrans;
  final String imagePath;

  MitutuglungCardData({
    required this.id,
    required this.kapampanganWord,
    required this.englishTrans,
    required this.imagePath,
  });
}

class WordData {
  final String baseForm;
  final String englishTrans;

  WordData({required this.baseForm, required this.englishTrans});
}

class TugakQuestionData {
  final String textWithBlank;
  final String correctTense;
  final String sentenceEng;
  final String pastTense;
  final String presentTense;
  final String futureTense;
  final String engPast;
  final String engPresent;
  final String engFuture;

  TugakQuestionData({
    required this.textWithBlank,
    required this.correctTense,
    required this.sentenceEng,
    required this.pastTense,
    required this.presentTense,
    required this.futureTense,
    required this.engPast,
    required this.engPresent,
    required this.engFuture,
  });

  List<String> get allTenseOptions => [pastTense, presentTense, futureTense];

  List<String> getOptions() => [pastTense, presentTense, futureTense];

  List<String> getEngOptions() => [engPast, engPresent, engFuture];
}

class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int score;
  final double accuracy;
  final int gamesPlayed;
  final int secondaryScore;
  final bool isOverallLeaderboard;
  final String gameType;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.accuracy,
    required this.gamesPlayed,
    this.secondaryScore = 0,
    this.isOverallLeaderboard = false,
    this.gameType = '',
    this.avatarUrl,
  });
}
