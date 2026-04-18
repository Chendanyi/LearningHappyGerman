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

Swift sources and JSON listed here live next to `LearnHappyGerman.xcodeproj` unless noted as nested under `LearnHappyGerman/LearnHappyGerman/`.

- `MainLobbyView.swift` — Lobby entrance UI with CEFR selector and first-run import progress bar.
- `FlashcardView.swift` — First classroom screen with answer validation, `AudioService` TTS (de-DE).
- `AudioService.swift` — `AVSpeechSynthesizer` German speech, mixed audio session.
- `HangmanGameView.swift` — Hangman classroom UI and SwiftData-backed rounds.
- `GrammarQuizView.swift` / `SentenceTemplate.swift` (nested `LearnHappyGerman/LearnHappyGerman/`) — A1 present-tense cloze; Hallway **Tenses**.
- `SimpleLifeBakeryDialogueView.swift` / `BakeryScenarioEngine.swift` — A1 bakery dialogue; Hallway **AI Dialogue**.
- `GermanFlashcardAnswerNormalization.swift` — Typed-answer comparison helper.
- `Theme.swift` — Shared color, typography, symmetry, and icon styling.
- `VocabularyWord.swift` — SwiftData vocabulary model and `CEFRLevel` for UI routing.
- `GrammarRule.swift` — Grammar rules (`title`, `explanation`, `level`, `exampleSentences`).
- `DataSeeder.swift` — Seed pipeline and bulk import from `full_vocabulary.json`.
- `LocalSeeder.swift` — First-launch ingestion from `BundledData.json`; audit appendix for `Documentation/MEMORY.md`.
- `SyncService.swift` — Remote JSON merge placeholder.
- `BundledData.json` / `initial_data.json` / `full_vocabulary.json` — bundled and generated corpora (also nested app copy where the target copies resources).
- `Resources/README.md` — notes for future bundle-only assets (canonical `full_vocabulary.json` remains beside the `.xcodeproj` today).

## Unit tests (`LearnHappyGerman/LearnHappyGermanTests/`)

- `LearnHappyGermanTests.swift` — default XCTest template / harness entry.
- `Logic/` — primary unit tests: `VocabularyWordTests`, `VocabularyDataIntegrityTests`, `VocabularySymmetryLayoutTests`, `FlashcardRegressionTests`, `SyncServiceTests`, `AudioServiceTests`, `BakeryScenarioTests`, `VocabularyA2FetchPerformanceTests`, `HangmanLogicTests`, `GrammarQuizTests`, etc.

## Quality gate

- `Scripts/check_integrity.sh` — SwiftLint + `Scripts/audit_data.swift` + `xcodebuild test`.
- `Scripts/pipeline.sh` — CI-style gate with fast-path; appends summaries to `Documentation/MEMORY.md`.

Last updated: 2026-04-18 (documentation and script layout reorg)
