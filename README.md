# 📦 remote_app_blocker  

[![Pub Version](https://img.shields.io/pub/v/remote_app_blocker.svg)](https://pub.dev/packages/remote_app_blocker)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_GITHUB_USERNAME/remote_app_blocker.svg?style=social)](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker)
[![Build](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker/actions/workflows/flutter.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker/actions/workflows/flutter.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

### Remotely block a Flutter app & show a custom message until payment or compliance is resolved.

`remote_app_blocker` is a Flutter package that lets developers remotely:

- 🚫 Block an app when a client refuses to pay  
- 🔐 Show a custom “App On Hold” message  
- 📡 Pull block status from **HTTP**, **Firestore**, or **Firebase Remote Config**  
- 🔄 Cache last decision when offline  
- 🗓️ Block based on **dates**  
- 🧩 Block specific **app versions**  
- 🔑 Support optional **HMAC integrity signing** (anti-tampering)  
- 🧱 Drop-in wrapper for any existing Flutter application  

This package is commonly used by freelancers and agencies who need a clean, non-invasive way to disable apps until invoices are paid — without modifying client code.

---

## 🖼 Screenshots

Default blocked page (light theme):

![Default blocked page (light)](screenshots/blocked-page-light.png)

Optional custom styling example:

![Custom blocked page](screenshots/blocked-page-dark.png)

> Place your PNG screenshots under `screenshots/` with the above names, or update paths accordingly.

---

## ✨ Features

- **Remote control** via JSON, Firestore, or Firebase Remote Config  
- **Block by flag** (`isBlocked = true`)  
- **Block specific app versions** (`blockedVersions`)  
- **Schedule-based blocking** (`blockFrom` / `blockUntil`)  
- **Custom message** from server (e.g.  
  `The App is currently on hold until the client pays the developer.`)  
- **Offline cache fallback**  
- **Optional HMAC signature verification** for remote config  
- **Simple integration** – wrap your app in one widget  

---

## 📥 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  remote_app_blocker: ^0.0.1


``` 
import 'package:flutter/material.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

void main() {
  runApp(const MyRoot());
}

class MyRoot extends StatelessWidget {
  const MyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return RemoteAppGate(
      appVersion: "1.0.0", // example — use package_info_plus to fetch real version

      providers: [
        HttpBlockStatusProvider(
          url: "https://yourdomain.com/app-status.json",
          hmacSecret: "SUPER_SECRET_KEY_CHANGE_ME", // optional but recommended
        ),
      ],

      blockedBuilder: (context, msg) {
        return Scaffold(
          backgroundColor: Colors.red.shade50,
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
      body: Center(child: Text("App Running Normally")),
    );
  }
}
```

🌐 Remote JSON Format (HTTP Source)
Upload a JSON file such as:
{
  "isBlocked": true,
  "blockMessage": "The App is currently on hold until the client pays the developer.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null
}

Unblock:
{
  "isBlocked": false,
  "blockMessage": "",
  "blockedVersions": []
}

⚙ Advanced Blocking Rules

🔹 Block a specific app version
{
  "isBlocked": false,
  "blockMessage": "This version is disabled.",
  "blockedVersions": ["1.0.0"]
}

🔹 Scheduled blocking (block between dates)
{
  "isBlocked": false,
  "blockMessage": "Access paused until payment is received.",
  "blockFrom": "2025-01-01T00:00:00Z",
  "blockUntil": "2025-01-31T23:59:59Z"
}
🔹 Forced block
{
  "isBlocked": true,
  "blockMessage": "Your access has been blocked. Contact the developer.",
  "blockedVersions": []
}

🔒 Optional Security (HMAC Signature)

To prevent clients from editing JSON on their own server, you can attach a signature:
{
  "isBlocked": true,
  "blockMessage": "App on hold.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null,
  "signature": "HEX_DIGEST_SHA256"
}

Using these fields (in this order):

isBlocked | blockMessage | blockedVersions | blockFrom | blockUntil

The Flutter package will recompute and verify this signature if hmacSecret is provided to HttpBlockStatusProvider.

See Automated HMAC signing scripts below for ready-made backend tools.

⸻

🔥 Firebase Support

Firestore

Create a document (e.g. apps/your_app_id) containing the same JSON schema.

Example document:
{
  "isBlocked": true,
  "blockMessage": "The App is currently on hold until the client pays the developer.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null
}
Use provider:
FirestoreBlockStatusProvider(
  firestore: FirebaseFirestore.instance,
  collectionPath: "apps",
  documentId: "your_app_id",
),

Firebase Remote Config

Set a parameter (e.g. app_block_config) to a JSON string with the same schema.

Use provider:
RemoteConfigBlockStatusProvider(
  remoteConfig: FirebaseRemoteConfig.instance,
  key: "app_block_config",
),

Nice, we’re going full “real open-source package” mode 😎
I’ll give you everything as copy-pasteable files and commands.

I’ll cover:
	1.	GitHub repo setup (structure + commands)
	2.	CHANGELOG.md
	3.	Updated README.md with shields.io badges + screenshots section
	4.	Screenshot file layout & how to generate them
	5.	HMAC signing scripts for backend (Node.js, Python, PHP)

⸻

1️⃣ GitHub Repository Setup

Suggested repo name

remote_app_blocker

Recommended structure

remote_app_blocker/
├─ lib/
│  └─ remote_app_blocker.dart
├─ example/
│  └─ main.dart
├─ screenshots/
│  ├─ blocked-page-light.png
│  └─ blocked-page-dark.png      # optional
├─ .github/
│  └─ workflows/
│     └─ flutter.yml             # CI (for build/test)
├─ pubspec.yaml
├─ README.md
├─ CHANGELOG.md
├─ LICENSE
└─ .gitignore

.gitignore (Flutter / Dart)

Create .gitignore:

# Flutter/Dart/Pub related
.dart_tool/
.packages
.pub-cache/
build/
pubspec.lock

# IntelliJ / Android Studio
*.iml
.idea/
.android/
.ios/

# VSCode
.vscode/

# Misc
.DS_Store

Git commands to create the repo

From inside remote_app_blocker/:

git init
git add .
git commit -m "chore: initial commit with remote app blocker package"
git branch -M main
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/remote_app_blocker.git
git push -u origin main

Replace YOUR_GITHUB_USERNAME with yours.

⸻

2️⃣ CHANGELOG.md

Create CHANGELOG.md in the root:

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.1] - 2025-11-24

### Added

- Initial release of `remote_app_blocker` Flutter package.
- `RemoteAppGate` widget that wraps an entire Flutter app and decides whether to:
  - Show the normal application, or
  - Show a customizable "App On Hold" / blocked screen.
- `RemoteBlockConfig` model for unified configuration across different sources.
- `BlockStatusProvider` abstraction for pluggable configuration providers.
- `HttpBlockStatusProvider` to fetch JSON configuration from a remote HTTP endpoint.
- `FirestoreBlockStatusProvider` to load configuration from a Firestore document.
- `RemoteConfigBlockStatusProvider` to load configuration from Firebase Remote Config.
- Default blocked page UI via `DefaultBlockedPage` widget.
- Configuration fields:
  - `isBlocked` flag for global blocking.
  - `blockMessage` for custom text such as:
    - "The App is currently on hold until the client pays the developer."
  - `blockedVersions` for version-specific blocking.
  - `blockFrom` / `blockUntil` for scheduled blocking windows.
- Offline / error handling:
  - Caching of last known decision and message via `SharedPreferences`.
  - Fallback to cached decision if remote providers fail.
- Optional HMAC-based integrity verification for HTTP JSON configurations:
  - Config validation against a server-side secret.
  - Protection against basic tampering of the remote JSON.
- Example app under `example/` showcasing:
  - HTTP-based configuration.
  - Custom blocked screen.
- Basic CI workflow template for Flutter in `.github/workflows/flutter.yml`.
- Initial documentation in `README.md`, including:
  - Setup instructions.
  - JSON configuration examples.
  - Provider usage.
  - Security considerations.

If you bump versions later, append new sections like ## [0.0.2] - YYYY-MM-DD.

⸻

3️⃣ Updated README.md (with badges + screenshots)

Here’s a full README.md including shields.io badges and screenshot section.
Update the URLs (GitHub username, repo name, pub.dev link) to your actual ones.

# 📦 remote_app_blocker  

[![Pub Version](https://img.shields.io/pub/v/remote_app_blocker.svg)](https://pub.dev/packages/remote_app_blocker)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_GITHUB_USERNAME/remote_app_blocker.svg?style=social)](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker)
[![Build](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker/actions/workflows/flutter.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker/actions/workflows/flutter.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

### Remotely block a Flutter app & show a custom message until payment or compliance is resolved.

`remote_app_blocker` is a Flutter package that lets developers remotely:

- 🚫 Block an app when a client refuses to pay  
- 🔐 Show a custom “App On Hold” message  
- 📡 Pull block status from **HTTP**, **Firestore**, or **Firebase Remote Config**  
- 🔄 Cache last decision when offline  
- 🗓️ Block based on **dates**  
- 🧩 Block specific **app versions**  
- 🔑 Support optional **HMAC integrity signing** (anti-tampering)  
- 🧱 Drop-in wrapper for any existing Flutter application  

This package is commonly used by freelancers and agencies who need a clean, non-invasive way to disable apps until invoices are paid — without modifying client code.

---

## 🖼 Screenshots

Default blocked page (light theme):

![Default blocked page (light)](screenshots/blocked-page-light.png)

Optional custom styling example:

![Custom blocked page](screenshots/blocked-page-dark.png)

> Place your PNG screenshots under `screenshots/` with the above names, or update paths accordingly.

---

## ✨ Features

- **Remote control** via JSON, Firestore, or Firebase Remote Config  
- **Block by flag** (`isBlocked = true`)  
- **Block specific app versions** (`blockedVersions`)  
- **Schedule-based blocking** (`blockFrom` / `blockUntil`)  
- **Custom message** from server (e.g.  
  `The App is currently on hold until the client pays the developer.`)  
- **Offline cache fallback**  
- **Optional HMAC signature verification** for remote config  
- **Simple integration** – wrap your app in one widget  

---

## 📥 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  remote_app_blocker: ^0.0.1

Until published on pub.dev, you can use a Git dependency:

dependencies:
  remote_app_blocker:
    git:
      url: https://github.com/YOUR_GITHUB_USERNAME/remote_app_blocker.git



⸻

🚀 Quick Start

Wrap your application with RemoteAppGate:

import 'package:flutter/material.dart';
import 'package:remote_app_blocker/remote_app_blocker.dart';

void main() {
  runApp(const MyRoot());
}

class MyRoot extends StatelessWidget {
  const MyRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return RemoteAppGate(
      appVersion: "1.0.0", // example — use package_info_plus to fetch real version

      providers: [
        HttpBlockStatusProvider(
          url: "https://yourdomain.com/app-status.json",
          hmacSecret: "SUPER_SECRET_KEY_CHANGE_ME", // optional but recommended
        ),
      ],

      blockedBuilder: (context, msg) {
        return Scaffold(
          backgroundColor: Colors.red.shade50,
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
      body: Center(child: Text("App Running Normally")),
    );
  }
}


⸻

🌐 Remote JSON Format (HTTP Source)

Upload a JSON file such as:

{
  "isBlocked": true,
  "blockMessage": "The App is currently on hold until the client pays the developer.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null
}

Unblock:

{
  "isBlocked": false,
  "blockMessage": "",
  "blockedVersions": []
}


⸻

⚙ Advanced Blocking Rules

🔹 Block a specific app version

{
  "isBlocked": false,
  "blockMessage": "This version is disabled.",
  "blockedVersions": ["1.0.0"]
}

🔹 Scheduled blocking (block between dates)

{
  "isBlocked": false,
  "blockMessage": "Access paused until payment is received.",
  "blockFrom": "2025-01-01T00:00:00Z",
  "blockUntil": "2025-01-31T23:59:59Z"
}

🔹 Forced block

{
  "isBlocked": true,
  "blockMessage": "Your access has been blocked. Contact the developer.",
  "blockedVersions": []
}


⸻

🔒 Optional Security (HMAC Signature)

To prevent clients from editing JSON on their own server, you can attach a signature:

{
  "isBlocked": true,
  "blockMessage": "App on hold.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null,
  "signature": "HEX_DIGEST_SHA256"
}

Using these fields (in this order):

isBlocked | blockMessage | blockedVersions | blockFrom | blockUntil

The Flutter package will recompute and verify this signature if hmacSecret is provided to HttpBlockStatusProvider.

See Automated HMAC signing scripts below for ready-made backend tools.

⸻

🔥 Firebase Support

Firestore

Create a document (e.g. apps/your_app_id) containing the same JSON schema.

Example document:

{
  "isBlocked": true,
  "blockMessage": "The App is currently on hold until the client pays the developer.",
  "blockedVersions": [],
  "blockFrom": null,
  "blockUntil": null
}

Use provider:

FirestoreBlockStatusProvider(
  firestore: FirebaseFirestore.instance,
  collectionPath: "apps",
  documentId: "your_app_id",
),


⸻

Firebase Remote Config

Set a parameter (e.g. app_block_config) to a JSON string with the same schema.

Use provider:

RemoteConfigBlockStatusProvider(
  remoteConfig: FirebaseRemoteConfig.instance,
  key: "app_block_config",
),


⸻

🧩 API Overview

Providers

Provider	Source	Use Case
HttpBlockStatusProvider	JSON over HTTP	Most freelancers/agencies
FirestoreBlockStatusProvider	Firestore document	Real-time, multi-tenant apps
RemoteConfigBlockStatusProvider	Firebase Remote Config	Feature flag / config toggles

Main Widget

RemoteAppGate(
  providers: [...],
  child: MaterialApp(...),
);


⸻

🧪 CI: GitHub Actions (Flutter)

Add this file as .github/workflows/flutter.yml:

name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

The badge at the top of this README points to this workflow.

⸻

⚙ Automated HMAC Signing Scripts (Backend)

Use these scripts to generate JSON + signature on the server side.

Node.js (CLI tool)

tools/sign-config.js:

#!/usr/bin/env node
const crypto = require("crypto");

const secret = process.env.RAB_HMAC_SECRET || "SUPER_SECRET_KEY_CHANGE_ME";

function signConfig(config) {
  const payload = [
    config.isBlocked,
    config.blockMessage || "",
    (config.blockedVersions || []).join(","),
    config.blockFrom || "",
    config.blockUntil || "",
  ].join("|");

  const signature = crypto
    .createHmac("sha256", secret)
    .update(payload)
    .digest("hex");

  return { ...config, signature };
}

// Example usage: node sign-config.js config.json > out.json
if (require.main === module) {
  const fs = require("fs");
  const inputPath = process.argv[2];

  if (!inputPath) {
    console.error("Usage: node sign-config.js <config.json>");
    process.exit(1);
  }

  const raw = fs.readFileSync(inputPath, "utf8");
  const config = JSON.parse(raw);
  const signed = signConfig(config);
  process.stdout.write(JSON.stringify(signed, null, 2));
}

module.exports = { signConfig };

Usage:

export RAB_HMAC_SECRET="SAME_SECRET_AS_IN_APP"
node tools/sign-config.js config.json > app-status.json


⸻

Python script

tools/sign_config.py:

#!/usr/bin/env python3
import hmac
import hashlib
import json
import os
import sys

SECRET = os.getenv("RAB_HMAC_SECRET", "SUPER_SECRET_KEY_CHANGE_ME")


def sign_config(config: dict) -> dict:
    payload = "|".join([
        str(config.get("isBlocked", False)),
        config.get("blockMessage", "") or "",
        ",".join(config.get("blockedVersions", []) or []),
        config.get("blockFrom", "") or "",
        config.get("blockUntil", "") or "",
    ])

    signature = hmac.new(
        SECRET.encode("utf-8"),
        payload.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()

    config["signature"] = signature
    return config


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: sign_config.py <config.json>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    with open(path, "r", encoding="utf-8") as f:
        config = json.load(f)

    signed = sign_config(config)
    print(json.dumps(signed, indent=2))

Usage:

export RAB_HMAC_SECRET="SAME_SECRET_AS_IN_APP"
python tools/sign_config.py config.json > app-status.json


⸻

PHP function

tools/sign_config.php:

<?php

function sign_config(array $config, string $secret): array
{
    $isBlocked = $config['isBlocked'] ?? false;
    $blockMessage = $config['blockMessage'] ?? '';
    $blockedVersions = isset($config['blockedVersions']) && is_array($config['blockedVersions'])
        ? implode(',', $config['blockedVersions'])
        : '';
    $blockFrom = $config['blockFrom'] ?? '';
    $blockUntil = $config['blockUntil'] ?? '';

    $payload = implode('|', [
        $isBlocked ? 'true' : 'false',
        $blockMessage,
        $blockedVersions,
        $blockFrom,
        $blockUntil,
    ]);

    $signature = hash_hmac('sha256', $payload, $secret);
    $config['signature'] = $signature;

    return $config;
}

You can use this in your Laravel/Symfony/vanilla PHP controller before returning JSON.

⸻

🖼 How to Create the Screenshot Files
	1.	Run the example app (example/main.dart) with a config that sets isBlocked = true.
	2.	Open the app in an emulator or physical device.
	3.	Take a screenshot:
	•	Save as blocked-page-light.png
	4.	(Optional) Switch to dark theme/custom page and take another screenshot:
	•	Save as blocked-page-dark.png
	5.	Place them under:

remote_app_blocker/screenshots/blocked-page-light.png
remote_app_blocker/screenshots/blocked-page-dark.png

They will automatically show via the image links in README.md.

⸻

❤️ Contributing

PRs and issues welcome.
If you want, I can next help you:
	•	Turn this into a real pub.dev package entry, or
	•	Wire package_info_plus into the example to auto-read appVersion.