import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/firebase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user stream
  static Stream<User?> get authStateChanges => FirebaseConfig.auth.authStateChanges();

  // Get current user
  static User? get currentUser => FirebaseConfig.currentUser;

  // Email/Password Sign Up
  static Future<UserProfile> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      UserCredential result = await FirebaseConfig.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
      }

      // Send email verification
      await result.user?.sendEmailVerification();

      // Create user profile
      UserProfile userProfile = UserProfile.fromFirebaseUser(result.user!);
      
      // Save to Firestore
      await _saveUserProfileToFirestore(userProfile);

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email/Password Sign In
  static Future<UserProfile> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await FirebaseConfig.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get or create user profile
      UserProfile userProfile = await _getUserProfile(result.user!);
      
      // Update last login
      UserProfile updatedProfile = userProfile.copyWith();
      await _saveUserProfileToFirestore(updatedProfile);

      return updatedProfile;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  static Future<UserProfile> signInWithGoogle() async {
    try {
      if (Platform.isIOS) {
        await _googleSignIn.signIn();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await FirebaseConfig.auth.signInWithCredential(credential);
      
      // Get or create user profile
      UserProfile userProfile = await _getUserProfile(result.user!);
      
      // Update last login
      UserProfile updatedProfile = userProfile.copyWith();
      await _saveUserProfileToFirestore(updatedProfile);

      return updatedProfile;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseConfig.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Password Reset
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseConfig.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update User Profile
  static Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      User? user = FirebaseConfig.currentUser;
      if (user != null) {
        await user.updateDisplayName(userProfile.displayName);
        await user.updatePhotoURL(userProfile.photoURL);
        await _saveUserProfileToFirestore(userProfile);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get User Profile from Firestore
  static Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseConfig.firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Private helper methods
  static Future<UserProfile> _getUserProfile(User user) async {
    UserProfile? existingProfile = await getUserProfile(user.uid);
    return UserProfile.fromFirebaseUser(user, existing: existingProfile);
  }

  static Future<void> _saveUserProfileToFirestore(UserProfile userProfile) async {
    try {
      await FirebaseConfig.firestore
          .collection('users')
          .doc(userProfile.uid)
          .set(userProfile.toFirestore());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
