# LearningHappyGerman

SwiftUI + SwiftData learning app structured around a lobby-and-classroom experience.

## What It Does
- Shows a Main Entrance lobby (`MainLobbyView`) for CEFR level check-in (`A1` to `C2`).
- Uses a symmetrical "Hotel Concierge Board" composition for level selection.
- Routes the Hallway "Flashcards" door to `FlashcardView` as the first classroom.
- On first launch, `LocalSeeder` reads `BundledData.json` from the bundle and imports words and grammar rules into SwiftData; counts are logged under Application Support (`MEMORY_ingestion_appendix.md`) for pasting into `MEMORY.md`. If that fails, a **Human Takeover** alert is shown.
- If the store is still empty afterward, `DataSeeder` supplies the built-in starter list (legacy fallback).
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
- `DataSeeder.swift`: A1-C2 import and seed-if-needed logic (fallback when bundled import did not fill the store).
- `LocalSeeder.swift`: Loads `BundledData.json` on first launch and writes ingestion audit lines for `MEMORY.md`.
- `BundledData.json`: Static corpus (vocabulary + optional grammar rules) shipped in the app bundle.
- `VocabularyWordTests.swift`: Evaluator guard test for noun/article validity.
- `.swiftlint.yml`: strict lint configuration and custom style/symmetry checks.
- `check_integrity.sh`: pipeline script (`swiftlint` + `swift test`) that fails fast on violations.
- `AGENTS.md` / `TODO.md` / `MEMORY.md`: Planner-Generator-Evaluator process docs.

## Troubleshooting
- If `ModelContainer` fails to create after a SwiftData schema or relationship change, delete the app from the simulator or device once so the on-disk store can be recreated (development builds do not always migrate every intermediate schema).
- **Black simulator screen:** Confirm the `LearnHappyGerman` scheme (not a test target) is running; open the **Debug area** (⇧⌘Y) and look for a crash or `fatalError`. Try **Simulator → Device → Erase All Content and Settings**, or quit and relaunch the Simulator app. The app attaches `modelContainer` to the root view and yields once before bundled import so the lobby can draw first.

Last updated: 2026-04-07 (SwiftData `modelContainer` on root view; first-frame yield before ingestion)
