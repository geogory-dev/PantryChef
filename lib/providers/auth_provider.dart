import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthProvider with ChangeNotifier {
  UserProfile? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Initialize auth state listener
  void initialize() {
    // Firebase removed - initialize without auth listener
    _user = null;
    _isLoading = false;
    _errorMessage = null;
  }

  // Email/Password Sign Up
  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase removed - simulate successful signup
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user profile
      _user = UserProfile(
        uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? email.split('@')[0],
        photoURL: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        dietaryPreferences: [],
        favoriteCuisines: [],
        preferences: {},
        isEmailVerified: false,
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Sign In
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase removed - simulate successful login
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user profile
      _user = UserProfile(
        uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        dietaryPreferences: [],
        favoriteCuisines: [],
        preferences: {},
        isEmailVerified: false,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase removed - simulate successful Google login
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user profile
      _user = UserProfile(
        uid: 'mock_google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        displayName: 'Google User',
        photoURL: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        dietaryPreferences: [],
        favoriteCuisines: [],
        preferences: {},
        isEmailVerified: true,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Firebase removed - just clear user state
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase removed - simulate password reset
      await Future.delayed(const Duration(seconds: 1));
      print('Password reset email sent to: $email');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
    List<String>? dietaryPreferences,
    List<String>? favoriteCuisines,
    Map<String, dynamic>? preferences,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase removed - update local user profile
      _user = _user!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
        dietaryPreferences: dietaryPreferences,
        favoriteCuisines: favoriteCuisines,
        preferences: preferences,
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user profile
  Future<void> refreshUserProfile() async {
    if (_user != null) {
      // Firebase removed - no remote profile to refresh
      print('Profile refresh (offline mode)');
    }
  }
}
