# ProjectMap

## Repository root

- `README.md` — product overview, commands, and layout (GitHub landing).
- `Documentation/` — `AGENTS.md`, `TODO.md`, `MEMORY.md`, `ProjectMap.md`, `HYBRID_DATA_ARCHITECTURE.md`, `NAVIGATION_ARCHITECTURE.md`.
- `Scripts/` — `check_integrity.sh`, `pipeline.sh`, `audit_data.swift`, `build_a2_500.py`, `audit_level_overlap.py`, `merge_a2_vocab_batch.py`, `vocab_processor.py`.
- `Data/` — placeholder for shared datasets (no canonical vocabulary here).
- `check_integrity.sh` — thin wrapper; runs `Scripts/check_integrity.sh` from repo root.
- `.cursorrules` — pre-task workflow constraints.
- `.swiftlint.yml` — strict lint policy (main paths under `LearnHappyGerman/`).
- `Package.swift` / `Package.resolved` — SPM tooling (e.g. snapshot testing); the iOS app builds from `LearnHappyGerman/LearnHappyGerman.xcodeproj`.

## Xcode project directory (`LearnHappyGerman/`)

Bundled JSON (`*.json`) lives next to `LearnHappyGerman.xcodeproj`. SwiftUI sources live under **`LearnHappyGerman/LearnHappyGerman/`**, grouped by feature (paths mirror test layout under `LearnHappyGermanTests/Features/`).

### App package (`LearnHappyGerman/LearnHappyGerman/`)

- **`Features/Lobby/`** — `MainLobbyView.swift`, `Theme.swift` (CEFR lobby + shared design tokens).
- **`Features/Flashcards/`** — `FlashcardView.swift`, `GermanFlashcardAnswerNormalization.swift`.
- **`Features/Hangman/`** — `HangmanGameView.swift`.
- **`Features/Grammar/`** — `GrammarQuizView.swift`, `SentenceTemplate.swift`, `GrammarRule.swift` (A1 tenses / cloze).
- **`Features/Bakery/`** — `BakeryScenarioEngine.swift`, `SimpleLifeBakeryDialogueView.swift` (AI dialogue room).
- **`Features/Vocabulary/`** — `VocabularyWord.swift`, `DataSeeder.swift`, `LocalSeeder.swift` (SwiftData model + seeding).
- **`Services/`** — `AudioService.swift`, `SyncService.swift`.
- **Package root** — `LearnHappyGermanApp.swift`, `ContentView.swift`, `Item.swift`, assets, previews.

### Data next to the `.xcodeproj`

- `BundledData.json` / `initial_data.json` / `full_vocabulary.json` — bundled and generated corpora (nested app copy where the target copies resources).
- `Resources/README.md` — notes for future bundle-only assets.

## Unit tests (`LearnHappyGerman/LearnHappyGermanTests/`)

- `LearnHappyGermanTests.swift` — default XCTest template / harness entry.
- **`Features/Flashcards/`** — `FlashcardRegressionTests.swift`.
- **`Features/Hangman/`** — `HangmanLogicTests.swift`.
- **`Features/Grammar/`** — `GrammarQuizTests.swift`.
- **`Features/Bakery/`** — `BakeryScenarioTests.swift`.
- **`Features/Vocabulary/`** — `VocabularyWordTests`, `VocabularyDataIntegrityTests`, `VocabularySymmetryLayoutTests`, `VocabularyA2FetchPerformanceTests`.
- **`Features/Services/`** — `AudioServiceTests`, `SyncServiceTests`.

## Quality gate

- `Scripts/check_integrity.sh` — SwiftLint + `Scripts/audit_data.swift` + `xcodebuild test`.
- `Scripts/pipeline.sh` — CI-style gate with fast-path; appends summaries to `Documentation/MEMORY.md`.

Last updated: 2026-04-18 (feature-based `Features/` + `Services/` source and test layout)
