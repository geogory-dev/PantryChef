class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
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
    required this.lastLoginAt,
    this.dietaryPreferences = const [],
    this.favoriteCuisines = const [],
    this.preferences = const {},
    this.isEmailVerified = false,
  });

  // Create from Firebase User
  factory UserProfile.fromFirebaseUser(User user, {UserProfile? existing}) {
    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: existing?.createdAt ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
      dietaryPreferences: existing?.dietaryPreferences ?? [],
      favoriteCuisines: existing?.favoriteCuisines ?? [],
      preferences: existing?.preferences ?? {},
      isEmailVerified: user.emailVerified,
    );
  }

  // Create from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []),
      favoriteCuisines: List<String>.from(data['favoriteCuisines'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isEmailVerified: data['isEmailVerified'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'dietaryPreferences': dietaryPreferences,
      'favoriteCuisines': favoriteCuisines,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
    };
  }

  // Create copy with updated fields
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    List<String>? dietaryPreferences,
    List<String>? favoriteCuisines,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastLoginAt: DateTime.now(),
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
