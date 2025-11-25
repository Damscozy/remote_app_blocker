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
