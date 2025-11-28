import 'package:flutter/material.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If you use Firebase-based providers, you must initialize Firebase here:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyRoot());
}

class MyRoot extends StatelessWidget {
  const MyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Pretend this is your version; in a real app use package_info_plus.
    const appVersion = "1.0.0";

    return RemoteAppGate(
      appVersion: appVersion,

      // Providers to check (first one with data wins)
      providers: [
        HttpBlockStatusProvider(
          url: "https://yourdomain.com/app-status.json",
          // optional secret: must match your server-side HMAC secret
          hmacSecret: "SUPER_SECRET_KEY_CHANGE_ME",
        ),

        // You can chain more providers; first one with data wins:
        // FirestoreBlockStatusProvider(
        //   firestore: FirebaseFirestore.instance,
        //   collectionPath: "apps",
        //   documentId: "your_app_id",
        // ),
        //
        // RemoteConfigBlockStatusProvider(
        //   remoteConfig: FirebaseRemoteConfig.instance,
        //   key: "app_block_config",
        // ),
      ],

      // Real-time updates via HTTP polling (every 10 minutes by default)
      // The UI will update dynamically when isBlocked changes!
      refreshInterval: const Duration(minutes: 10),

      // Custom animation settings
      animationDuration: const Duration(milliseconds: 800),
      animationCurve: Curves.easeInOutBack,

      // Easy customization without a full builder
      blockedPageStyle: BlockedPageStyle(
        backgroundColor: Colors.grey.shade900,
        cardColor: Colors.grey.shade800,
        titleStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        messageStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        icon: Icons.cloud_off_rounded,
        iconColor: Colors.redAccent,
        borderRadius: BorderRadius.circular(24),
      ),

      // Callback when status changes
      onStatusChanged: (isBlocked, message) {
        debugPrint('Status changed: $isBlocked');
        // You can:
        // - Show a snackbar
        // - Send analytics
        // - Trigger notifications
      },

      // Custom blocked page (optional; default is DefaultBlockedPage)
      blockedBuilder: (context, msg) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },

      // Normal app when not blocked
      child: MaterialApp(
        title: 'Remote App Blocker Demo',
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Main App Running Normally")),
    );
  }
}
