# Tajweed

Flutter app for Tajweed lessons and practice sessions, with optional online
question loading from Firebase Firestore.

## Firebase Online Practice (Initial Implementation)

When the user enables `مصدر أسئلة متصل` in the practice setup screen:
- The app tries to load questions from Firestore collection
  `practice_questions`.
- If Firestore is unavailable, not configured, or returns no valid questions,
  the app falls back automatically to local offline generation.

### Firestore Document Shape

Collection: `practice_questions`

Required fields per document:
- `enabled`: `bool`
- `practiceType`: `string` (`mcq`, `trueFalse`, `letterMatch`, `sectionMatch`)
- `ruleId`: `string` (must match a local Tajweed rule id)
- `prompt`: `string`

For `mcq`, `trueFalse`, `sectionMatch`:
- `options`: `array<string>` (at least 2 options)
- `correctOptionIndex`: `int` (within options range)

For `letterMatch`:
- `sourceText`: `string` (ayah/snippet shown as tappable letters)
- `validLetters`: `array<string>` (one or more correct Arabic letters)

Optional fields:
- `explanation`: `string`

### Setup Notes

1. Add Firebase to each target platform (Android/iOS/web) in the project.
2. Ensure `Firebase.initializeApp()` can succeed for your target platform.
3. Run dependency install:
   - `flutter pub get`

If Firebase is not configured yet, the app still runs and keeps practice
working with offline questions.
