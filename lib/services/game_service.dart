import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import './auth_service.dart';

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

      // Check if user is guest through AuthService
      final authService = AuthService();
      if (authService.isGuest) return 0;

      final userRecord = await _supabase
          .from('users')
          .select('user_id')
          .eq('auth_id', user.id)
          .single();

      final userId = userRecord['user_id'];

      // Get total score from user_game_progress table
      final progressData = await _supabase
          .from('user_game_progress')
          .select('total_score')
          .eq('user_id', userId);

      // Sum all total_score values across all games
      int totalScore = 0;
      for (var progress in progressData) {
        totalScore += (progress['total_score'] as int? ?? 0);
      }

      print('Total score for this user: $totalScore');

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
    // Get current progress
    final currentProgress = await _supabase
        .from('user_game_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('game_type', gameType)
        .single();

    final newGamesPlayed = currentProgress['games_played'] + 1;
    final newTotalScore = currentProgress['total_score'] + score;
    final currentAvg = currentProgress['average_accuracy'] ?? 0;
    final newAvgAccuracy =
        ((currentAvg * currentProgress['games_played']) + accuracy) /
            newGamesPlayed;

    // Difficulty progression
    String newDifficulty = _calculateNewDifficulty(
      gameType,
      currentProgress['current_difficulty'],
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
              (currentProgress['best_secondary_score'] ?? 0) as int,
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
      // Go down one difficulty
      switch (currentDifficulty) {
        case 'advanced':
          return 'intermediate';
        case 'intermediate':
          return 'beginner';
        case 'beginner':
          return 'beginner'; // Stay at beginner
        default:
          return 'beginner';
      }
    } else if (avgAccuracy >= 70) {
      // Go up one difficulty
      switch (currentDifficulty) {
        case 'beginner':
          return 'intermediate';
        case 'intermediate':
          return 'advanced';
        case 'advanced':
          return 'advanced'; // Stay at advanced
        default:
          return currentDifficulty;
      }
    } else {
      // 30-69% accuracy: retain current difficulty
      return currentDifficulty;
    }
  }

  // =========== QUESTIONS FETCHING ===============

  Future<List<WordData>> getWordsByDifficulty(
      {required String difficulty}) async {
    try {
      // First, get total count of words for this difficulty
      final response = await _supabase
          .from('words')
          .select('base_form, english_trans')
          .eq('word_difficulty', difficulty);

      final words = response
          .map<WordData>((row) => WordData(
                baseForm: row['base_form'] as String,
                englishTrans: row['english_trans'] as String,
              ))
          .toList();

      print('Fetched ${words.length} words for difficulty $difficulty');

      return words;
    } catch (e) {
      print('Error fetching random words: $e');
      rethrow;
    }
  }
}

// ============== HELPER CLASSES ==============
class WordData {
  final String baseForm;
  final String englishTrans;

  WordData({required this.baseForm, required this.englishTrans});
}
