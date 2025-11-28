# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.4] - 2025-11-28

### Added
- Real-time block status updates via `refreshInterval` and Stream-based providers
- `onStatusChanged` callback for monitoring block status changes
- `initTimeout` parameter to prevent indefinite loading (default 10s)
- `didUpdateWidget` support for dynamic configuration changes
- `BlockedPageStyle` for easy UI customization
- `AnimatedSwitcher` for smooth transitions
- `animationDuration` and `animationCurve` parameters
- Improved example with Firebase real-time updates

### Fixed
- Fixed README.md formatting issues (code blocks, section headers, tables)
- Updated documentation to reflect current version
- Improved example code structure and comments
- Optimized initialization logic and memory management

### Changed
- **BREAKING**: Removed `cacheLastDecision` parameter and SharedPreferences caching
- Changed default `refreshInterval` from 5 minutes to 10 minutes
- Firebase/Firestore providers now rely purely on real-time streams
- HTTP provider uses polling only (no cache fallback)

## [0.0.2] - 2025-11-25

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