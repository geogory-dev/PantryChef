class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> dietaryPreferences;
  final List<String> favoriteCuisines;
  final Map<String, dynamic> preferences;
  final bool isEmailVerified;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLogin,
    this.dietaryPreferences = const [],
    this.favoriteCuisines = const [],
    this.preferences = const {},
    this.isEmailVerified = false,
  });

  // Create from mock data
  UserProfile.fromMockData({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.dietaryPreferences = const [],
    this.favoriteCuisines = const [],
    this.preferences = const {},
    this.isEmailVerified = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'dietaryPreferences': dietaryPreferences,
      'favoriteCuisines': favoriteCuisines,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
    };
  }

  // Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      favoriteCuisines: List<String>.from(json['favoriteCuisines'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  // Create copy with updated fields
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    List<String>? dietaryPreferences,
    List<String>? favoriteCuisines,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    DateTime? lastLogin,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastLogin: lastLogin ?? DateTime.now(),
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
