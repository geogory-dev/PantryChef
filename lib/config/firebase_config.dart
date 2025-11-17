import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    if (_app == null) {
      _app = await Firebase.initializeApp(
        options: kIsWeb ? getWebOptions() : getDefaultOptions(),
      );
      _auth = FirebaseAuth.instanceFor(app: _app!);
      _firestore = FirebaseFirestore.instanceFor(app: _app!);
      
      // Enable offline persistence for Firestore
      await _firestore!.enablePersistence(const PersistenceSettings(enable: true));
    }
  }

  // Get Firebase App instance
  static FirebaseApp get app {
    if (_app == null) {
      throw Exception('Firebase not initialized. Call initializeFirebase() first.');
    }
    return _app!;
  }

  // Get Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call initializeFirebase() first.');
    }
    return _auth!;
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initializeFirebase() first.');
    }
    return _firestore!;
  }

  // Default Firebase options (for mobile)
  static FirebaseOptions getDefaultOptions() {
    return const FirebaseOptions(
      apiKey: 'your-api-key-here',
      appId: 'your-app-id-here',
      messagingSenderId: 'your-sender-id-here',
      projectId: 'your-project-id-here',
      storageBucket: 'your-storage-bucket-here',
      authDomain: 'your-auth-domain-here',
    );
  }

  // Web Firebase options
  static FirebaseOptions getWebOptions() {
    return const FirebaseOptions(
      apiKey: 'your-web-api-key-here',
      appId: 'your-web-app-id-here',
      messagingSenderId: 'your-sender-id-here',
      projectId: 'your-project-id-here',
      storageBucket: 'your-storage-bucket-here',
      authDomain: 'your-auth-domain-here',
    );
  }

  // Check if user is logged in
  static bool get isLoggedIn => auth.currentUser != null;

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }
}
