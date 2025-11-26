library;

import 'dart:async';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration model that can come from HTTP, Firestore, or Remote Config.
class RemoteBlockConfig {
  final bool isBlocked;
  final String message;
  final List<String> blockedVersions;
  final DateTime? blockFrom;
  final DateTime? blockUntil;

  const RemoteBlockConfig({
    required this.isBlocked,
    required this.message,
    required this.blockedVersions,
    this.blockFrom,
    this.blockUntil,
  });

  factory RemoteBlockConfig.fromJson(Map<String, dynamic> json) {
    final versionsRaw = json['blockedVersions'];
    final blockedVersions = versionsRaw is List
        ? versionsRaw.map((e) => e.toString()).toList()
        : <String>[];

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.trim().isEmpty) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return RemoteBlockConfig(
      isBlocked: (json['isBlocked'] ?? false) == true,
      message: (json['blockMessage'] ?? '').toString(),
      blockedVersions: blockedVersions,
      blockFrom: parseDate(json['blockFrom']),
      blockUntil: parseDate(json['blockUntil']),
    );
  }
}

/// Abstract provider for loading config from any source.
abstract class BlockStatusProvider {
  Future<RemoteBlockConfig?> loadConfig();
}

/// HTTP JSON provider.
/// Endpoint should return JSON with fields like:
/// {
///   "isBlocked": true,
///   "blockMessage": "...",
///   "blockedVersions": ["1.0.0"],
///   "blockFrom": "2025-01-01T00:00:00Z",
///   "blockUntil": "2025-01-31T23:59:59Z",
///   "signature": "..." // optional HMAC
/// }
class HttpBlockStatusProvider implements BlockStatusProvider {
  final String url;
  final Duration timeout;
  final String? hmacSecret;
  final List<String> hmacFields;

  HttpBlockStatusProvider({
    required this.url,
    this.timeout = const Duration(seconds: 5),
    this.hmacSecret,
    this.hmacFields = const [
      'isBlocked',
      'blockMessage',
      'blockedVersions',
      'blockFrom',
      'blockUntil',
    ],
  });

  @override
  Future<RemoteBlockConfig?> loadConfig() async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(
          timeout,
          onTimeout: () {
            throw Exception('HTTP timeout');
          },
        );

    if (response.statusCode != 200) return null;

    final Map<String, dynamic> data = jsonDecode(response.body);

    // If using HMAC, verify signature
    if (hmacSecret != null) {
      final signature = data['signature']?.toString();
      if (signature == null || signature.isEmpty) {
        return null;
      }
      final computed = _computeHmac(data);
      if (computed != signature) {
        // Data might be tampered with.
        return null;
      }
    }

    return RemoteBlockConfig.fromJson(data);
  }

  String _computeHmac(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    for (final key in hmacFields) {
      if (buffer.isNotEmpty) buffer.write('|');
      final value = json[key];
      if (value is List) {
        buffer.write(value.join(','));
      } else {
        buffer.write(value?.toString() ?? '');
      }
    }
    final payload = buffer.toString();
    final hmacSha = Hmac(sha256, utf8.encode(hmacSecret!));
    return hmacSha.convert(utf8.encode(payload)).toString();
  }
}

/// Firestore provider.
/// Document data should match RemoteBlockConfig JSON schema.
class FirestoreBlockStatusProvider implements BlockStatusProvider {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final String documentId;

  FirestoreBlockStatusProvider({
    required this.firestore,
    required this.collectionPath,
    required this.documentId,
  });

  @override
  Future<RemoteBlockConfig?> loadConfig() async {
    final doc = await firestore
        .collection(collectionPath)
        .doc(documentId)
        .get();

    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;

    return RemoteBlockConfig.fromJson(Map<String, dynamic>.from(data));
  }
}

/// Firebase Remote Config provider.
/// The given key should be a JSON string following RemoteBlockConfig schema.
class RemoteConfigBlockStatusProvider implements BlockStatusProvider {
  final FirebaseRemoteConfig remoteConfig;
  final String key;

  RemoteConfigBlockStatusProvider({
    required this.remoteConfig,
    required this.key,
  });

  @override
  Future<RemoteBlockConfig?> loadConfig() async {
    await remoteConfig.fetchAndActivate();
    final jsonString = remoteConfig.getString(key);
    if (jsonString.isEmpty) return null;

    final Map<String, dynamic> data = jsonDecode(jsonString);
    if (kDebugMode) {
      print(data);
    }
    return RemoteBlockConfig.fromJson(data);
  }
}

/// Top-level gate widget.
/// Wrap this around your entire app in `runApp(RemoteAppGate(...))`.
class RemoteAppGate extends StatefulWidget {
  /// One or more providers. The first provider that returns a config wins.
  final List<BlockStatusProvider> providers;

  /// The actual app to run when not blocked.
  final Widget child;

  /// Custom blocked UI.
  final Widget Function(BuildContext context, String message)? blockedBuilder;

  /// What to show while loading configuration.
  final Widget? loading;

  /// What to show if there is an error AND no cached decision is available.
  /// Defaults to [child] (i.e. allow the app).
  final Widget? errorPage;

  /// Current app version (e.g. "1.0.0").
  /// Use package_info_plus or similar to get this and pass it in.
  final String? appVersion;

  /// Whether to cache last decision (blocked/unblocked) locally.
  final bool cacheLastDecision;

  /// How often to check for configuration updates.
  /// Set to Duration.zero to disable periodic refresh.
  /// Default is 5 minutes.
  final Duration refreshInterval;

  /// Callback when the block status changes.
  /// Useful for analytics or notifications.
  final void Function(bool isBlocked, String message)? onStatusChanged;

  const RemoteAppGate({
    super.key,
    required this.providers,
    required this.child,
    this.blockedBuilder,
    this.loading,
    this.errorPage,
    this.appVersion,
    this.cacheLastDecision = true,
    this.refreshInterval = const Duration(minutes: 5),
    this.onStatusChanged,
  });

  @override
  State<RemoteAppGate> createState() => _RemoteAppGateState();
}

class _RemoteAppGateState extends State<RemoteAppGate> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBlocked = false;
  String _message = '';
  Timer? _refreshTimer;

  static const _prefsBlockedKey = 'rab_isBlocked';
  static const _prefsMessageKey = 'rab_message';

  @override
  void initState() {
    super.initState();
    _init();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    if (widget.refreshInterval > Duration.zero) {
      _refreshTimer = Timer.periodic(widget.refreshInterval, (_) {
        _refreshConfig();
      });
    }
  }

  /// Manually refresh the block configuration.
  /// Useful for pull-to-refresh or manual checks.
  Future<void> _refreshConfig() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      RemoteBlockConfig? config;

      for (final provider in widget.providers) {
        config = await provider.loadConfig();
        if (config != null) break;
      }

      if (config != null) {
        final newIsBlocked = _evaluateConfig(config, widget.appVersion);
        final newMessage = config.message.isEmpty
            ? 'The app is currently unavailable.'
            : config.message;

        // Only update if status changed
        if (newIsBlocked != _isBlocked || newMessage != _message) {
          if (mounted) {
            setState(() {
              _isBlocked = newIsBlocked;
              _message = newMessage;
              _hasError = false;
            });
          }

          // Notify callback
          widget.onStatusChanged?.call(_isBlocked, _message);

          // Update cache
          if (widget.cacheLastDecision) {
            await prefs.setBool(_prefsBlockedKey, _isBlocked);
            await prefs.setString(_prefsMessageKey, _message);
          }
        }
      }
    } catch (_) {
      // Silently fail on refresh errors - keep current state
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      RemoteBlockConfig? config;

      for (final provider in widget.providers) {
        config = await provider.loadConfig();
        if (config != null) break;
      }

      if (config == null) {
        // No provider gave data – try cache
        final cachedBlocked = prefs.getBool(_prefsBlockedKey);
        final cachedMessage = prefs.getString(_prefsMessageKey);

        if (cachedBlocked != null) {
          _isBlocked = cachedBlocked;
          _message = cachedMessage ?? '';
          _hasError = false;
        } else {
          _hasError = true;
        }
      } else {
        _isBlocked = _evaluateConfig(config, widget.appVersion);
        _message = config.message.isEmpty
            ? 'The app is currently unavailable.'
            : config.message;
        _hasError = false;

        // Notify callback on initial load
        widget.onStatusChanged?.call(_isBlocked, _message);

        if (widget.cacheLastDecision) {
          await prefs.setBool(_prefsBlockedKey, _isBlocked);
          await prefs.setString(_prefsMessageKey, _message);
        }
      }
    } catch (_) {
      // On error, fallback to cache
      final cachedBlocked = prefs.getBool(_prefsBlockedKey);
      final cachedMessage = prefs.getString(_prefsMessageKey);

      if (cachedBlocked != null) {
        _isBlocked = cachedBlocked;
        _message = cachedMessage ?? '';
        _hasError = false;
      } else {
        _hasError = true;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _evaluateConfig(RemoteBlockConfig config, String? appVersion) {
    bool blocked = config.isBlocked;

    // Version-based blocking
    if (appVersion != null &&
        config.blockedVersions.contains(appVersion.trim())) {
      blocked = true;
    }

    // Schedule-based blocking
    final now = DateTime.now().toUtc();
    final from = config.blockFrom?.toUtc();
    final until = config.blockUntil?.toUtc();

    if (from != null && until != null) {
      if (now.isAfter(from) && now.isBefore(until)) {
        blocked = true;
      }
    } else if (from != null && until == null) {
      if (now.isAfter(from)) {
        blocked = true;
      }
    } else if (from == null && until != null) {
      if (now.isBefore(until)) {
        blocked = true;
      }
    }

    return blocked;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loading ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      // If error and no cache: either show error page or allow app.
      return widget.errorPage ?? widget.child;
    }

    if (_isBlocked) {
      final msg = _message.isEmpty
          ? 'The app is currently on hold until the client pays the developer.'
          : _message;

      if (widget.blockedBuilder != null) {
        return widget.blockedBuilder!(context, msg);
      }

      return DefaultBlockedPage(message: msg);
    }

    return widget.child;
  }
}

/// Default blocked page UI. You can override using [blockedBuilder].
class DefaultBlockedPage extends StatelessWidget {
  final String message;
  const DefaultBlockedPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 48),
              const SizedBox(height: 16),
              Text(
                "App On Hold",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
