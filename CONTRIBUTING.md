# Contributing

Thanks for contributing to Tajweed.

## Scope

This project is an Arabic-first Tajweed learning app based on *Tuhfat Al-Atfal*.
Please keep contributions educationally accurate and consistent with the app's
existing style and architecture.

## Development Setup

1. Install Flutter SDK (compatible with `Dart ^3.10.7`).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Before Opening a Pull Request

Run local checks:

```bash
dart format .
dart analyze
flutter test
```

## Pull Request Guidelines

- Keep PRs focused and small when possible.
- Explain what changed and why.
- Include screenshots for UI changes.
- Note any behavior changes for online/offline practice.
- Update `README.md` when user-visible functionality changes.

## Content and Rule Accuracy

When editing Tajweed content in `lib/data/tajweed_content.dart`:

- Keep `ruleId` values stable once published (important for analytics/history).
- Ensure verses from the poem match the related rule.
- Add at least one practical example per new rule.
- Keep Arabic text fully proofread before submission.

## Online Practice Data Compatibility

Firestore documents in `practice_questions` should follow the schema documented
in `README.md`. Changes to that schema must be reflected in both:

- `README.md`
- `lib/services/firebase_practice_source_service.dart`

## Reporting Security Issues

Do not open public issues for sensitive security reports. Contact the
maintainer privately first.
