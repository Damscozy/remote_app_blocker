import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

// IMPORTANT: To use this example, you MUST:
// 1. Set up a Firebase project at https://console.firebase.google.com
// 2. Add your platform-specific Firebase configuration files:
//    - Android: android/app/google-services.json
//    - iOS: ios/Runner/GoogleService-Info.plist
//    - Web: web/firebase-config.js
// 3. Run: flutter pub add firebase_core cloud_firestore firebase_remote_config
// 4. Run: flutterfire configure (installs Firebase CLI if needed)
// 5. This will generate lib/firebase_options.dart automatically

// After running 'flutterfire configure', uncomment these lines:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - uncomment after running 'flutterfire configure':
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyFirebaseApp());
}

class MyFirebaseApp extends StatelessWidget {
  const MyFirebaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appVersion = "1.0.0";

    return RemoteAppGate(
      appVersion: appVersion,

      // Provider priority order (first one with data wins)
      providers: [
        // Option 1: Firebase Remote Config Provider
        // Set up in Firebase Console:
        // 1. Go to Remote Config section
        // 2. Add parameter: app_block_config
        // 3. Set value to JSON string, e.g.:
        //    {"isBlocked": true, "blockMessage": "App on hold", "blockedVersions": []}
        RemoteConfigBlockStatusProvider(
          remoteConfig: FirebaseRemoteConfig.instance,
          key: "app_block_config",
        ),

        // Option 2: Firestore Provider
        // Set up in Firestore:
        // 1. Create collection: apps
        // 2. Create document: your_app_id
        // 3. Add fields:
        //    - isBlocked: true/false
        //    - blockMessage: "Your message"
        //    - blockedVersions: ["1.0.0"]
        FirestoreBlockStatusProvider(
          firestore: FirebaseFirestore.instance,
          collectionPath: "apps",
          documentId: "your_app_id",
        ),

        // Option 3: HTTP as fallback
        HttpBlockStatusProvider(
          url: "https://yourdomain.com/app-status.json",
          hmacSecret: "SUPER_SECRET_KEY_CHANGE_ME",
        ),
      ],

      // Check for updates every 1 minute (good for Firebase)
      // Remote Config updates will be detected automatically!
      refreshInterval: const Duration(minutes: 1),

      // Get notified when block status changes
      onStatusChanged: (isBlocked, message) {
        debugPrint('🔔 Block status changed: isBlocked=$isBlocked');
        debugPrint('📝 Message: $message');
        // Perfect for:
        // - Showing user notifications
        // - Logging to Firebase Analytics
        // - Triggering app-wide state changes
      },

      blockedBuilder: (context, msg) {
        return Scaffold(
          backgroundColor: Colors.red.shade50,
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "App On Hold",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      child: MaterialApp(
        title: 'Remote App Blocker - Firebase Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'App Running Normally',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Connected to Firebase',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Dummy action
              },
              icon: const Icon(Icons.cloud),
              label: const Text('Firebase Ready'),
            ),
          ],
        ),
      ),
    );
  }
}
