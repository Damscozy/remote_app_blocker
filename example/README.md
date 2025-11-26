# Remote App Blocker - Example App

This directory contains two example apps demonstrating how to use the `remote_app_blocker` package.

## Examples Provided

### 1. HTTP Example (default - `lib/main.dart`)

The simplest example using HTTP-based configuration. **No additional setup required.**

**Features:**
- HTTP-based configuration with HMAC security
- Custom blocked page UI
- Proper app version handling
- Works immediately after `flutter run`

### 2. Firebase Example (`lib/main_firebase.dart`)

Advanced example showing Firebase Remote Config and Firestore providers. **Requires Firebase setup.**

**Features:**
- Firebase Remote Config integration
- Firestore database integration
- Multiple provider fallback strategy
- Real-time configuration updates

**To use:** See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for complete setup instructions.

---

## Quick Start (HTTP Example)

### Run the HTTP Example

```bash
flutter pub get
flutter run
```

This runs `lib/main.dart` which uses `HttpBlockStatusProvider`.

### Configuration

The example uses `HttpBlockStatusProvider` to fetch block configuration from:
```
https://yourdomain.com/app-status.json
```

### Test Blocking

1. Create a JSON file on your server with this structure:

   **Block the app:**
   ```json
   {
     "isBlocked": true,
     "blockMessage": "The App is currently on hold until the client pays the developer.",
     "blockedVersions": [],
     "blockFrom": null,
     "blockUntil": null
   }
   ```

   **Unblock the app:**
   ```json
   {
     "isBlocked": false,
     "blockMessage": "",
     "blockedVersions": []
   }
   ```

2. Update the URL in `lib/main.dart` line 27 to point to your JSON file

3. Run the app - it will fetch the configuration and show either:
   - The blocked page if `isBlocked: true`
   - The normal app if `isBlocked: false`

---

## Running Firebase Example

### Prerequisites

Before running the Firebase example, you need to:

1. Set up a Firebase project
2. Configure Firebase for Flutter
3. Initialize Firebase services

**See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.**

### Quick Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (creates firebase_options.dart)
flutterfire configure

# Run Firebase example
flutter run -t lib/main_firebase.dart
```

Then set up Remote Config or Firestore in Firebase Console (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)).

---

## Customization

### Custom Blocked Page

Both examples show how to customize the blocked page UI using the `blockedBuilder` parameter:

```dart
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
```

### App Version Detection

To get the real app version instead of using a hardcoded string, add `package_info_plus`:

```yaml
dependencies:
  package_info_plus: ^8.0.0
```

Then in your code:
```dart
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = packageInfo.version; // e.g., "1.0.0"
  
  runApp(MyRoot(appVersion: appVersion));
}
```

---

## Provider Comparison

| Provider | Setup Complexity | Update Speed | Offline Support | Best For |
|----------|-----------------|--------------|-----------------|----------|
| **HTTP** | Easy ⭐ | Manual restart | Yes (cached) | Freelancers, simple apps |
| **Remote Config** | Medium ⭐⭐ | Auto (12hr cache) | Yes (cached) | Feature flags, AB testing |
| **Firestore** | Medium ⭐⭐ | Real-time | Yes (cached) | Multi-tenant, complex rules |

### Multiple Providers

You can use multiple providers with automatic fallback:

```dart
providers: [
  RemoteConfigBlockStatusProvider(...),  // Try this first
  FirestoreBlockStatusProvider(...),     // Fallback to this
  HttpBlockStatusProvider(...),          // Final fallback
],
```

The **first provider that returns data wins**!

---

## Learn More

- [Package Documentation](https://pub.dev/packages/remote_app_blocker)
- [GitHub Repository](https://github.com/Damscozy/remote_app_blocker)
- [Firebase Setup Guide](FIREBASE_SETUP.md) - For Firebase example

