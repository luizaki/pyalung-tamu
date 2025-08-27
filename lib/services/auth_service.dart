import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../models/player.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  Player? _currentPlayer;

  Player? get currentPlayer => _currentPlayer;
  bool get isLoggedIn => _currentPlayer != null && !_currentPlayer!.isGuest;
  bool get isGuest => _currentPlayer?.isGuest ?? false;

  // ================== DEBUGGER SETUP ==================

  void _log(String message) {
    if (kDebugMode) {
      print('AuthService: $message');
    }
  }

  void _logError(String message, [dynamic error]) {
    if (kDebugMode) {
      print('AuthService Error: $message');
      if (error != null) print('AuthService Error: $error');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print('AuthService Warning: $message');
    }
  }

  // ================== INITIALIZATION ==================

  Future<void> initialize() async {
    _log('Initializing AuthService...');

    // Listen for auth state changes (email verification, login, etc.)
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      _log('Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        _handleUserSignedIn(session!.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentPlayer = null;
      }
    });

    // Check if user is already logged in with Supabase Auth
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user);
    } else {
      await _checkGuestMode();
    }
  }

  Future<void> _handleUserSignedIn(User user) async {
    _log('User signed in: ${user.email}');

    // Check if user profile exists in our users table
    final existing = await _supabase
        .from('users')
        .select('*')
        .eq('auth_id', user.id)
        .maybeSingle();

    if (existing == null) {
      _logWarning('No profile found, creating one...');
      final storedUsername = user.userMetadata?['username'] as String?;
      final username = storedUsername ?? 'User${user.id.substring(0, 8)}';

      try {
        await _createUserProfile(user, username);
        await _loadUserProfile(user);
      } catch (e) {
        _logError('Error creating delayed profile: $e');
      }
    } else {
      _currentPlayer = Player.fromJson(existing, email: user.email);
      _log('Loaded existing user profile: ${_currentPlayer?.username}');
    }
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuestMode = prefs.getBool('is_guest_mode') ?? false;

    if (isGuestMode) {
      _currentPlayer = Player.guest();
      _log('Restored guest mode');
    }
  }

  // ================== AUTHENTICATION ==================

  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      _log('Attempting login for: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          return AuthResult.error(
            'Please verify your email address before logging in. Check your email for the verification link.',
          );
        }

        await _loadUserProfile(response.user!);

        if (_currentPlayer == null) {
          _logWarning(
              'No profile found during login, checking if we need to create one...');
          await _handleUserSignedIn(response.user!);
        }

        await _clearGuestMode();

        _log('Login successful for: ${_currentPlayer?.username}');
        return AuthResult.success('Login successful!');
      } else {
        return AuthResult.error('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      _logError('Login error: ${e.message}');
      return AuthResult.error(_getReadableAuthError(e.message));
    } catch (e) {
      _logError('Login error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _log('Attempting registration for: $email');

      // Check if username is already taken in users table
      final existingUser = await _supabase
          .from('users')
          .select('user_id')
          .eq('user_name', username)
          .maybeSingle();

      if (existingUser != null) {
        return AuthResult.error(
            'Username is already taken. Please choose another.');
      }

      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        if (response.session == null) {
          // Email confirmation required - user will get verification email
          _log('Email verification required for: $email');
          return AuthResult.success(
            'Please check your email and click the verification link to complete registration.',
          );
        } else {
          await _createUserProfile(response.user!, username);
          await _loadUserProfile(response.user!);
          await _clearGuestMode();

          _log('Registration successful for: $username');
          return AuthResult.success(
              'Account created successfully! Welcome $username!');
        }
      } else {
        return AuthResult.error('Registration failed. Please try again.');
      }
    } on AuthException catch (e) {
      _logError('Registration error: ${e.message}');
      return AuthResult.error(_getReadableAuthError(e.message));
    } catch (e) {
      _logError('Registration error: $e');
      return AuthResult.error(
          'An unexpected error occurred. Please try again.');
    }
  }

  Future<void> loginAsGuest() async {
    _log('Logging in as guest');

    _currentPlayer = Player.guest();

    // Save guest mode to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', true);
  }

  Future<void> logout() async {
    _log('Logging out...');

    await _supabase.auth.signOut();
    _currentPlayer = null;

    // Clear preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_guest_mode');

    _log('Logout complete');
  }

  // ================== DATABASE OPERATIONS ==================

  Future<void> _loadUserProfile(User authUser) async {
    try {
      // Look for user in users table by auth_id
      final data = await _supabase
          .from('users')
          .select('*')
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (data != null) {
        _currentPlayer = Player.fromJson(data, email: authUser.email);
        _log('Loaded user profile: ${_currentPlayer?.username}');
      } else {
        _logError('No user profile found for auth user ${authUser.id}');
        // User exists in auth but not in users table - this shouldn't happen
        // but we can handle it gracefully
        _currentPlayer = null;
      }
    } catch (e) {
      _logError('Error loading user profile: $e');
    }
  }

  Future<void> _createUserProfile(User authUser, String username) async {
    try {
      // Generate a unique user_id
      final userId = await _generateUniqueUserId();

      await _supabase.from('users').insert({
        'user_id': userId,
        'auth_id': authUser.id, // Link to Supabase auth user
        'user_name': username,
        'avatar': 'boy.PNG', // Default avatar
        'total_score': 0,
      });

      _log('Created user profile for: $username');
    } catch (e) {
      _logError('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<int> _generateUniqueUserId() async {
    // Generate a random user ID and check if it's unique
    final random = Random();
    int userId;

    do {
      userId = random.nextInt(999999999) + 100000000; // 9-digit number

      final existing = await _supabase
          .from('users')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) break; // ID is unique
    } while (true);

    return userId;
  }

  Future<void> _clearGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_guest_mode');
  }

  String _getReadableAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (error.contains('User already registered')) {
      return 'An account with this email already exists. Please try logging in.';
    }
    if (error.contains('Password should be at least 6 characters')) {
      return 'Password must be at least 6 characters long.';
    }
    if (error.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    }
    return error;
  }

  // ================== VALIDATION ==================

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ================== UPDATE AVATAR ===================

  Future<AuthResult> updateAvatar(String newAvatar) async {
    if (_currentPlayer == null || _currentPlayer!.isGuest) {
      return AuthResult.error('You must be logged in to change your avatar.');
    }

    try {
      await _supabase
          .from('users')
          .update({'avatar': newAvatar}).eq('auth_id', _currentPlayer!.authId!);

      _currentPlayer = _currentPlayer!.copyWith(avatar: newAvatar);
      _log('Avatar updated to: $newAvatar');
      return AuthResult.success('Avatar updated successfully!');
    } catch (e) {
      _logError('Error updating avatar: $e');
      return AuthResult.error('Failed to update avatar. Please try again.');
    }
  }
}

// ================== RESULT CLASSES ==================

class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._(this.isSuccess, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
