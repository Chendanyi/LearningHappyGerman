# LearningHappyGerman

SwiftUI + SwiftData learning app structured around a lobby-and-classroom experience.

## What It Does
- Shows a Main Entrance lobby (`MainLobbyView`) for CEFR level check-in (`A1` to `C2`).
- Uses a symmetrical "Hotel Concierge Board" composition for level selection.
- Routes the Hallway "Flashcards" door to `FlashcardView` as the first classroom.
- On first launch, `LocalSeeder` reads `BundledData.json` from the bundle and imports words and grammar rules into SwiftData; counts are logged under Application Support (`MEMORY_ingestion_appendix.md`) for pasting into `MEMORY.md`. If that fails, a **Human Takeover** alert is shown.
- If the store is still empty afterward, `DataSeeder` supplies the built-in starter list (legacy fallback).
- Uses SwiftData hybrid models: `VocabularyWord` (UUID `id`, `version`, indexed `germanWord` + `level` as `String`, optional `article`, `category` as `String`) and `GrammarRule` (`title`, `explanation`, `level`, `exampleSentences`). Store file: Application Support `LearnHappyGerman/learnhappygerman-v9.store`, with in-memory fallback if opening the file fails.
- Applies shared design tokens from `Theme.swift` (palette, typography, symmetry, icon style).
- Enforces a quality gate with SwiftLint + tests via `check_integrity.sh`.
  - Runs `swiftlint` and `xcodebuild test` for the `LearnHappyGerman` scheme.

## Project Layout
- `MainLobbyView.swift`: Main Entrance (Lobby) UI and level-selection interactions.
- `FlashcardView.swift`: First classroom with `FetchDescriptor` vocabulary filtered by `AppState.currentLevel` (no `@Query`, to avoid macro temp-file tooling issues), Check (case-insensitive + article for noun-like rows), success sound/animation and `isMastered` on correct, LobbyBoyPurple wrong-answer hint, **Next** only after a check.
- `Theme.swift`: App design tokens and layout/icon helpers.
- `VocabularyWord.swift`: SwiftData vocabulary model (UUID, `version`, indexed `germanWord`/`level` strings) and `CEFRLevel` enum for UI routing only.
- `GrammarRule.swift`: SwiftData grammar content (`title`, `explanation`, `level`, `exampleSentences`).
- `DataSeeder.swift`: A1-C2 import and seed-if-needed logic (fallback when bundled import did not fill the store).
- `LocalSeeder.swift`: Loads `BundledData.json` on first launch and writes ingestion audit lines for `MEMORY.md`.
- `SyncService.swift`: Placeholder remote JSON fetch + merge into SwiftData (dedupe by word + level; preserves `isMastered`). See `SyncServiceTests`.
- `BundledData.json`: Static corpus (vocabulary + grammar rules with `exampleSentences` arrays) shipped in the app bundle.
- `initial_data.json`: 30 A1 vocabulary rows (themes `Daily Life`, `Activities`, `Travel`, `Home`, `People`, `Time`, plus verbs); merged into SwiftData on launch via `LocalSeeder.mergeInitialDataFromBundle()` (skips rows already present for the same `germanWord` + `level`). `BundledData.json` still ships the smaller cross-level sample; A1 richness comes from this merge.
- `VocabularyWordTests.swift`: Evaluator guard test for noun/article validity.
- `VocabularyDataIntegrityTests.swift`: Article + CEFR level invariants on seeded data; `DataSeeder.seedIfNeeded` idempotency (no duplicates on second run).
- `VocabularySymmetryLayoutTests.swift`: Grand Budapest symmetric layout tokens + `Theme.VocabularyGrandBudapest` contract used by vocabulary UI.
- `SyncServiceTests.swift`: Remote merge test; updated gloss preserves `isMastered`.
- `.swiftlint.yml`: strict lint configuration and custom style/symmetry checks.
- `check_integrity.sh`: pipeline script (`swiftlint` + `swift test`) that fails fast on violations.
- `AGENTS.md` / `TODO.md` / `MEMORY.md`: Planner-Generator-Evaluator process docs.

## Troubleshooting
- If `ModelContainer` fails to create after a SwiftData schema or relationship change, delete the app from the simulator or device once so the on-disk store can be recreated (development builds do not always migrate every intermediate schema).
- **Black simulator screen:** Confirm the `LearnHappyGerman` scheme (not a test target) is running; open the **Debug area** (⇧⌘Y) and look for a crash or `fatalError`. Try **Simulator → Device → Erase All Content and Settings**, or quit and relaunch the Simulator app. The app attaches `modelContainer` to the root view and yields once before bundled import so the lobby can draw first.

Last updated: 2026-04-07 (FlashcardView: `FetchDescriptor` instead of `@Query` to avoid macro temp-path tooling errors; SwiftLint excludes `swift-generated-sources`)
