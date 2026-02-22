<p align="center">
  <img src="assets/branding/tajweed_logo.svg" alt="Tajweed logo" width="132" />
</p>

<h1 align="center">Tajweed - Tuhfat Al-Atfal</h1>

<p align="center">
  A modern Arabic-first Tajweed learning app built with Flutter.
  <br />
  Structured lessons, guided practice, and progress analysis in one place.
</p>

## Overview

**Tajweed** is an educational mobile app focused on rules from **Tuhfat Al-Atfal**.
It combines:

- Lesson browsing by section and rule.
- Rule details with examples and verses from the poem.
- Interactive practice sessions.
- Performance analysis from saved attempts.
- Optional online question source via Firestore, with offline fallback.

## Current Feature Set

- Arabic RTL interface with Arabic numerals and readable typography.
- 6 lesson sections and 27 Tajweed rules currently included in local content.
- Rule details include:
  - Definition.
  - Relevant letters.
  - Practical examples.
  - Study tip.
  - Related verses from *Tuhfat Al-Atfal* (supports multiple verses per rule).
- Practice modes:
  - Multiple Choice (`mcq`).
  - True / False (`trueFalse`).
  - Letter Match (`letterMatch`).
  - Section Match (`sectionMatch`).
- Practice scope control:
  - All rules.
  - Specific section.
  - Specific rule.
- Session length control:
  - Question count mode.
  - Timed mode.
- Results screen with mistakes review and explanations.
- Analysis screen with:
  - Overall stats.
  - Weakest rules.
  - Strongest rules.
  - Recent attempts history.
- Local persistence of attempts using `SharedPreferences`.
- Optional Firestore question loading with automatic fallback to offline generation.

## Tech Stack

- Flutter
- Dart (`^3.10.7`)
- `shared_preferences`
- `firebase_core` (optional runtime integration)
- `cloud_firestore` (optional online question source)
- `google_fonts`

## Project Structure

```text
lib/
  app.dart
  main.dart
  data/
    tajweed_content.dart
  models/
    practice_models.dart
    tajweed_models.dart
  screens/
    lessons_screen.dart
    section_rules_screen.dart
    rule_details_screen.dart
    practice/
      practice_setup_screen.dart
      practice_session_screen.dart
      practice_result_screen.dart
    analysis_screen.dart
  services/
    practice_engine_service.dart
    firebase_practice_source_service.dart
    practice_storage_service.dart
```

## Getting Started

### Prerequisites

- Flutter SDK compatible with this project (`Dart ^3.10.7`).
- Android Studio or Xcode for platform builds.

### Install and Run

```bash
flutter pub get
flutter run
```

### Quality Checks

```bash
dart analyze
flutter test
```

## Optional Online Practice (Firestore)

Online mode is intentionally simple:

- No authentication.
- No user accounts.
- Questions are managed manually in Firebase Console.
- App reads from Firestore only when the user enables online source in practice setup.
- If Firebase is unavailable or returns invalid/empty data, app falls back to offline questions automatically.

### Firestore Collection

Use collection: `practice_questions`

### Document Schema

| Field | Type | Required | Notes |
|---|---|---|---|
| `enabled` | `bool` | Yes | `true` means this document is active and can be used. |
| `practiceType` | `string` | Yes | One of: `mcq`, `trueFalse`, `letterMatch`, `sectionMatch`. |
| `ruleId` | `string` | Yes | Must match a local rule id from `lib/data/tajweed_content.dart`. |
| `prompt` | `string` | Yes | Question text shown to the user. |
| `options` | `array<string>` | Yes | At least 2 options. |
| `correctOptionIndex` | `int` | Yes | Zero-based index inside `options`. |
| `explanation` | `string` | No | Extra explanation shown in results. |

### What `ruleId` Means

`ruleId` links an online question to a specific local Tajweed rule. This is required so:

- Rule-level analysis stays accurate.
- Scope filters (all/section/rule) still work.
- Online and offline results can be merged consistently.

## Privacy and Data

- No account system.
- No personal profile data.
- Practice history is stored locally on-device.
- Network access is only relevant when online practice source is enabled.

## Branding Assets

- App logo and splash assets live in `assets/branding/`.
- Native splash generation uses `flutter_native_splash`.
- Launcher icons generation uses `flutter_launcher_icons`.

Regenerate when assets/config change:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

## Release Notes for Publishing

Before publishing to GitHub Releases and F-Droid, review these items:

- Replace placeholder Android application id in `android/app/build.gradle.kts` (`com.example.tajweed`) with your final id.
- Configure proper release signing (current release config still uses debug signing).
- Verify copyright holder/year in `LICENSE` if needed for your release.
- Prepare store metadata (description, screenshots, changelog, privacy notes).
- If shipping Firebase online mode, document that external network service in your metadata.

## Contributing

Contributions are welcome.

- Open an issue for bugs or suggestions.
- Submit focused pull requests with clear descriptions.
- Run `dart analyze` before opening a PR.

Contribution guide: `CONTRIBUTING.md`

## License

This project is licensed under the **MIT License**.

See `LICENSE` for full text.
