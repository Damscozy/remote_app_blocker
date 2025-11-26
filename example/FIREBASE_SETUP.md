# Firebase Example Setup

This example demonstrates how to use `remote_app_blocker` with Firebase providers (Remote Config and Firestore).

## Prerequisites

Before running this example, you need to set up Firebase for your project.

## Setup Steps

### 1. Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Or use dart pub
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase for Your Project

```bash
# Navigate to the example directory
cd example

# Login to Firebase (if not already)
firebase login

# Configure Firebase for this Flutter project
flutterfire configure
```

This will:
- Create a Firebase project (or let you select an existing one)
- Generate platform-specific configuration files
- Create `lib/firebase_options.dart` automatically

### 3. Update Example to Use Firebase

Rename or copy the Firebase example file:

```bash
# Option 1: Replace main.dart with Firebase example
cp lib/main_firebase.dart lib/main.dart

# Option 2: Or just run the Firebase example directly
flutter run -t lib/main_firebase.dart
```

### 4. Set Up Firebase Remote Config

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Remote Config** in the left sidebar
4. Click **Add parameter**
5. Set:
   - **Parameter key:** `app_block_config`
   - **Default value:** 
     ```json
     {
       "isBlocked": false,
       "blockMessage": "",
       "blockedVersions": []
     }
     ```
6. Click **Publish changes**

**To block the app:**
Change the value to:
```json
{
  "isBlocked": true,
  "blockMessage": "The app is currently on hold. Please contact support.",
  "blockedVersions": []
}
```

### 5. Set Up Firestore (Optional)

1. In Firebase Console, navigate to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Create a collection called `apps`
5. Add a document with ID `your_app_id`
6. Add these fields:
   - `isBlocked` (boolean): `false`
   - `blockMessage` (string): `""`
   - `blockedVersions` (array): `[]`

**Example Firestore Document:**

```
Collection: apps
Document ID: your_app_id

Fields:
  isBlocked: false
  blockMessage: ""
  blockedVersions: []
  blockFrom: null
  blockUntil: null
```

### 6. Update Security Rules (Important!)

For production, you should secure your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /apps/{appId} {
      // Only allow reads (no writes from client)
      allow read: if true;
      allow write: if false;
    }
  }
}
```

For Remote Config, no security rules needed - it's read-only by default.

## Running the Example

```bash
# Make sure you're in the example directory
cd example

# Get dependencies
flutter pub get

# Run with Firebase example
flutter run -t lib/main_firebase.dart

# Or if you replaced main.dart:
flutter run
```

## How It Works

The example uses **multiple providers** in order of priority:

1. **RemoteConfigBlockStatusProvider** - Checks Firebase Remote Config first
2. **FirestoreBlockStatusProvider** - Falls back to Firestore if Remote Config returns nothing
3. **HttpBlockStatusProvider** - Final fallback to HTTP endpoint

The first provider that returns data wins!

## Testing Blocking

### Using Remote Config:

1. Open Firebase Console → Remote Config
2. Edit `app_block_config` parameter
3. Set to:
   ```json
   {"isBlocked": true, "blockMessage": "Payment required!"}
   ```
4. Publish changes
5. Restart your app (Remote Config caches for 12 hours by default)

### Using Firestore:

1. Open Firebase Console → Firestore
2. Navigate to `apps/your_app_id`
3. Edit the `isBlocked` field to `true`
4. Edit `blockMessage` to your custom message
5. Restart your app (changes are real-time!)

## Troubleshooting

### "Firebase not initialized" error

Make sure you:
1. Ran `flutterfire configure`
2. Uncommented the Firebase initialization code in `main_firebase.dart`
3. Imported `firebase_options.dart`

### "Document does not exist" with Firestore

1. Check the collection path: `apps`
2. Check the document ID matches: `your_app_id`
3. Make sure Firestore is initialized in Firebase Console

### Remote Config not updating

Remote Config has a default cache of 12 hours. To reduce during development:

```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: const Duration(minutes: 1), // Dev only!
));
```

## Best Practices

1. **Use Remote Config for simple on/off switches** - Fast, cached, no database reads
2. **Use Firestore for complex rules** - Real-time updates, version-specific rules
3. **Keep HTTP as fallback** - Works even if Firebase is down
4. **Test blocking in development** - Don't block production without testing!
5. **Set up monitoring** - Use Firebase Analytics to track blocked users

## Dependencies Required

Add these to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_remote_config: ^5.0.0
```

Run:
```bash
flutter pub get
```

## Learn More

- [Firebase Setup for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Remote Config Documentation](https://firebase.google.com/docs/remote-config)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Package Documentation](https://pub.dev/packages/remote_app_blocker)
