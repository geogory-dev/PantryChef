# Firebase Setup Guide for PantryChef

This guide will help you set up Firebase for authentication and cloud sync functionality in PantryChef.

## 🚀 Prerequisites

- Google account
- Firebase project
- Flutter development environment

## 📋 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "pantrychef-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

## 🔧 Step 2: Configure Firebase Services

### Enable Authentication
1. In Firebase Console, go to "Authentication" → "Get started"
2. Enable "Email/Password" sign-in method
3. Enable "Google" sign-in method
4. Configure Google sign-in with your project's OAuth consent screen

### Enable Firestore Database
1. Go to "Firestore Database" → "Create database"
2. Choose "Start in test mode" (for development)
3. Select a location (choose closest to your users)
4. Click "Create database"

### Setup Storage (Optional for future features)
1. Go to "Storage" → "Get started"
2. Follow the setup wizard
3. Configure security rules

## 📱 Step 3: Add Firebase to Flutter

### Android Configuration
1. In Firebase Console, go to Project Settings
2. Click "Add app" → Android
3. Use package name: `com.example.pantrychef`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### iOS Configuration
1. In Firebase Console, click "Add app" → iOS
2. Use bundle ID: `com.example.pantrychef`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

## 🔑 Step 4: Configure Environment Variables

1. Copy `.env.example` to `.env`
2. Add your Firebase configuration:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_actual_api_key_here
FIREBASE_APP_ID=your_actual_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_actual_sender_id_here
FIREBASE_PROJECT_ID=your_actual_project_id_here
FIREBASE_STORAGE_BUCKET=your_actual_storage_bucket_here
FIREBASE_AUTH_DOMAIN=your_actual_auth_domain_here
```

### Where to find these values:
- Go to Firebase Console → Project Settings → General
- Scroll down to "Your apps" section
- Click on your app to see the config values

## ⚙️ Step 5: Update Firebase Config

Update `lib/config/firebase_config.dart` with your environment variables:

```dart
static FirebaseOptions getDefaultOptions() {
  return FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
  );
}
```

## 🏃 Step 6: Run the App

```bash
flutter pub get
flutter run
```

## 📊 Step 7: Firestore Security Rules

For development, use these test rules in Firestore Console → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow access to user's collections
      match /recipes/{recipeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /mealPlans/{planId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /shoppingLists/{listId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /foodDiary/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 🧪 Step 8: Test Authentication

1. Run the app
2. You should see the login screen
3. Test email/password signup
4. Test Google sign-in
5. Verify user data in Firestore Console

## 🔧 Troubleshooting

### Common Issues

**"Firebase not initialized" Error**
- Ensure you've called `FirebaseConfig.initializeFirebase()` in main()
- Check that your environment variables are correctly set

**Google Sign-In Not Working**
- Verify SHA-1 fingerprint is added to Firebase Console
- For Android: `keytool -list -v -keystore ~/.android/debug.keystore`
- For iOS: Check bundle ID matches Firebase configuration

**Firestore Permission Denied**
- Check security rules in Firebase Console
- Ensure user is authenticated before accessing data

**Build Errors**
- Run `flutter clean` and `flutter pub get`
- Check platform-specific configuration files

### Debug Tips

1. Enable debug logging:
```dart
await Firebase.initializeApp(options: options);
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

2. Check Firebase Console for real-time data
3. Use Flutter Inspector for debugging UI
4. Monitor network requests in Firebase Console

## 🚀 Production Deployment

Before deploying to production:

1. **Update Security Rules** - Implement proper access controls
2. **Enable App Check** - Protect your backend resources
3. **Set up Monitoring** - Use Firebase Crashlytics
4. **Configure Analytics** - Track user behavior
5. **Test on Real Devices** - Ensure everything works in production

## 📚 Additional Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

---

**Note**: This setup guide is for development purposes. For production deployment, ensure proper security measures and monitoring are in place.
