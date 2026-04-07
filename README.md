# LearningHappyGerman

SwiftUI + SwiftData learning app structured around a lobby-and-classroom experience.

## What It Does
- Shows a Main Entrance lobby (`MainLobbyView`) for CEFR level check-in (`A1` to `C2`).
- Uses a symmetrical "Hotel Concierge Board" composition for level selection.
- Routes the Hallway "Flashcards" door to `FlashcardView` as the first classroom.
- Seeds starter CEFR vocabulary (`A1` to `C2`) on first launch if the local store is empty.
- Uses SwiftData hybrid models: `VocabularyWord` (with `version`; level uses `CEFRLevel`) and `GrammarRule` (optional `applicableLevelCode` + link to a headword). Store file: Application Support `LearnHappyGerman/learnhappygerman-v8.store`, with in-memory fallback if opening the file fails.
- Applies shared design tokens from `Theme.swift` (palette, typography, symmetry, icon style).
- Enforces a quality gate with SwiftLint + tests via `check_integrity.sh`.
  - Runs `swiftlint` and `xcodebuild test` for the `LearnHappyGerman` scheme.

## Project Layout
- `MainLobbyView.swift`: Main Entrance (Lobby) UI and level-selection interactions.
- `FlashcardView.swift`: First classroom with card prompt, answer input, and article-aware validation feedback.
- `Theme.swift`: App design tokens and layout/icon helpers.
- `VocabularyWord.swift`: SwiftData vocabulary model (versioned) and CEFR/article/category definitions.
- `GrammarRule.swift`: SwiftData grammar content (explanations, examples, rules) with optional link to a vocabulary word.
- `DataSeeder.swift`: A1-C2 import and seed-if-needed logic.
- `VocabularyWordTests.swift`: Evaluator guard test for noun/article validity.
- `.swiftlint.yml`: strict lint configuration and custom style/symmetry checks.
- `check_integrity.sh`: pipeline script (`swiftlint` + `swift test`) that fails fast on violations.
- `AGENTS.md` / `TODO.md` / `MEMORY.md`: Planner-Generator-Evaluator process docs.

## Troubleshooting
- If `ModelContainer` fails to create after a SwiftData schema or relationship change, delete the app from the simulator or device once so the on-disk store can be recreated (development builds do not always migrate every intermediate schema).

Last updated: 2026-04-07 (ModelContainer: versioned store URL + in-memory fallback; GrammarRule level as String code)
