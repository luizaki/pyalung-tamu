class Player {
  final String? authId; // from Supabase Auth
  final int? userId; // from users table
  final String? username;
  final String? email; // from Supabase Auth
  final int? totalScore;
  final String? avatar;
  final bool isGuest;

  Player({
    this.authId,
    this.userId,
    this.username,
    this.email,
    this.totalScore,
    this.avatar,
    this.isGuest = false,
  });

  factory Player.guest() {
    return Player(
      authId: 'guest',
      username: 'Guest',
      avatar: 'boy.PNG',
      isGuest: true,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json, {String? email}) {
    return Player(
      authId: json['auth_id'] as String?,
      userId: json['user_id'] as int?,
      username: json['user_name'] as String?,
      email: email,
      totalScore: json['total_score'] as int?,
      avatar: json['avatar'] as String?,
      isGuest: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_id': authId,
      'user_id': userId,
      'user_name': username,
      'total_score': totalScore,
      'avatar': avatar,
    };
  }

  Player copyWith({
    String? authId,
    int? userId,
    String? username,
    String? email,
    int? totalScore,
    String? avatar,
    bool? isGuest,
  }) {
    return Player(
      authId: authId ?? this.authId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      totalScore: totalScore ?? this.totalScore,
      avatar: avatar ?? this.avatar,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  String toString() =>
      'Player(authId: $authId, userId: $userId, username: $username, email: $email, isGuest: $isGuest)';
}
