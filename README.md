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

**Tajweed** is an educational app focused on rules from **Tuhfat Al-Atfal**.
It combines:

- Lesson browsing by section and rule.
- Rule details with examples and verses from the poem.
- Interactive practice sessions with multiple modes.
- Performance analysis from saved attempts.
- Android update checks from GitHub Releases.
- A public `web/` PWA landing page for downloads and screenshots.

## Current Feature Set

- Arabic RTL interface with Arabic numerals and Beiruti typography.
- System-aware theming:
  - Light theme.
  - Dark theme.
- 6 lesson sections and 27 Tajweed rules in local content.
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
  - Definition Match (`definitionMatch`).
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

## Recent Changes (v1.0.4)

### Added

- Release-build internet permission required for in-app update checks.
- Explicit `User-Agent` for GitHub Releases API update requests.
- New Android release artifacts and checksums for `v1.0.4`.

### Changed

- Website Android download link updated to the `v1.0.4` arm64 APK.
- App version bumped to `1.0.4+5`.

### Removed

- Outdated README references to Firebase/Firestore online question source.
- Outdated README references to non-existent Firebase service files and dependencies.

## Tech Stack

- Flutter
- Dart (`^3.10.7`)
- `google_fonts`
- `shared_preferences`
- `package_info_plus`
- `url_launcher`
- `flutter_svg`

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
    app_splash_screen.dart
    home_screen.dart
    lessons_screen.dart
    section_rules_screen.dart
    rule_details_screen.dart
    analysis_screen.dart
    practice/
      practice_setup_screen.dart
      practice_session_screen.dart
      practice_result_screen.dart
  services/
    practice_engine_service.dart
    practice_storage_service.dart
    update_checker_service.dart
  theme/
    app_theme.dart
  widgets/
    fade_slide_in.dart
    mono_numbers_text.dart
web/
  index.html
  manifest.json
  sw.js
  screenshots/
release/
  v1.0.1/
  v1.0.1-apk/
  v1.0.3/
  v1.0.3-apk/
  v1.0.4/
  v1.0.4-apk/
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
```

## App Update Check (Android)

- Implemented in `lib/services/update_checker_service.dart`.
- Checks latest GitHub Release from:
  - owner: `Soko9`
  - repo: `vearth-tajweed`
- Behavior:
  - Android only.
  - Prefers `arm64-v8a` APK asset if available.
  - Falls back to any APK asset or release page URL.

## Landing PWA (Download Page)

The `web/` folder is configured as a **static PWA landing page** (not Flutter web UI) to publish app information globally with:

- App overview and features.
- Screenshot section.
- Android/iOS download buttons.
- Installable website behavior (PWA).
- Auto dark-mode styling (`prefers-color-scheme`).

### Configure Download Links

Edit these links in `web/index.html`:

- Android button (`id="android-link"`).
- iOS button (`id="ios-link"`).

Notes:

- Android direct download can point to GitHub Release APK assets.
- iOS button is currently placeholder (`#`) until an App Store/TestFlight URL is available.

### Deploy to GitHub Pages

This repository includes:

- `.github/workflows/deploy-pwa-pages.yml`

It deploys `web/` automatically on pushes to `main` or `master` (or manual run).

## Release Artifacts

Current published release: **v1.0.4**

- GitHub release page:
  - `https://github.com/Soko9/vearth-tajweed/releases/tag/v1.0.4`
- AAB + hash:
  - `release/v1.0.4/tajweed-v1.0.4.aab`
  - `release/v1.0.4/tajweed-v1.0.4.aab.sha256`
- APK set + checksums:
  - `release/v1.0.4-apk/tajweed-v1.0.4-arm64-v8a.apk`
  - `release/v1.0.4-apk/tajweed-v1.0.4-armeabi-v7a.apk`
  - `release/v1.0.4-apk/tajweed-v1.0.4-x86_64.apk`
  - `release/v1.0.4-apk/SHA256SUMS.txt`

## Privacy and Data

- No account system.
- No personal profile data.
- Practice history is stored locally on-device.
- Network is used for:
  - Android update checks (GitHub Releases API).
  - PWA hosting/download links.

## Branding Assets

- App logo and splash assets live in `assets/branding/`.
- Native splash generation uses `flutter_native_splash`.
- Launcher icons generation uses `flutter_launcher_icons`.

Regenerate when assets/config change:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

## Contributing

Contributions are welcome.

- Open an issue for bugs or suggestions.
- Submit focused pull requests with clear descriptions.
- Run `dart analyze` before opening a PR.

Contribution guide: `CONTRIBUTING.md`

## License

This project is licensed under the **MIT License**.

See `LICENSE` for full text.
