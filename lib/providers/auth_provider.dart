import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

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
    AuthService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserProfile(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserProfile? userProfile = await AuthService.getUserProfile(uid);
      if (userProfile != null) {
        _user = userProfile;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Sign Up
  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await AuthService.signUpWithEmail(email, password, displayName: displayName);
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

      _user = await AuthService.signInWithEmail(email, password);
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

      _user = await AuthService.signInWithGoogle();
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

      await AuthService.signOut();
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

      await AuthService.sendPasswordResetEmail(email);
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

      UserProfile updatedProfile = _user!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
        dietaryPreferences: dietaryPreferences,
        favoriteCuisines: favoriteCuisines,
        preferences: preferences,
      );

      await AuthService.updateUserProfile(updatedProfile);
      _user = updatedProfile;
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
      await _loadUserProfile(_user!.uid);
    }
  }
}
