# ProjectMap

## Repository root

- `README.md` — product overview, commands, and layout (GitHub landing).
- `Documentation/` — `AGENTS.md`, `TODO.md`, `MEMORY.md`, `ProjectMap.md`, `HYBRID_DATA_ARCHITECTURE.md`, `NAVIGATION_ARCHITECTURE.md`.
- `Scripts/` — `check_integrity.sh`, `pipeline.sh`, `audit_data.swift` (quality gate scripts for lint/data/tests).
- `reference/vocabulary/` — optional Goethe PDF sources; see `reference/vocabulary/README.md`.
- `Data/scripts/` — `extract_vocab.py`, `cleanup_german_vocabulary.py`, `requirements-pdf-extract.txt` (PDF → `Data/german_vocabulary.json`; optional `--translate` / `--translate-only` fills `englishTranslation` via **googletrans**, needs network; cleanup script fixes plural/example leaks and strips CJK).
- `Data/` — `**german_vocabulary.json`**, `**grammar_rules.json`** (A1 grammar, JSON `version` 3), `**README.md**` (bundle schema + grammar rule index), and `Data/scripts/`; Xcode copies the JSON into the app target at build time (`project.pbxproj` → `../Data/*.json`).
- `check_integrity.sh` — thin wrapper; runs `Scripts/check_integrity.sh` from repo root.
- `.cursorrules` — pre-task workflow constraints.
- `.swiftlint.yml` — strict lint policy (main paths under `LearnHappyGerman/`).
- `Package.swift` / `Package.resolved` — SPM tooling (e.g. snapshot testing); the iOS app builds from `LearnHappyGerman/LearnHappyGerman.xcodeproj`.

## Xcode project directory (`LearnHappyGerman/`)

Bundled JSON (`*.json`) lives next to `LearnHappyGerman.xcodeproj`. SwiftUI sources live under `**LearnHappyGerman/LearnHappyGerman/**`, grouped by feature (paths mirror test layout under `LearnHappyGermanTests/Features/`).

### App package (`LearnHappyGerman/LearnHappyGerman/`)

- `**Features/Lobby/**` — `MainLobbyView.swift`, `Theme.swift` (CEFR lobby + shared design tokens).
- `**Features/Flashcards/**` — `FlashcardView.swift`, `FlashcardView+Preview.swift`, `GermanFlashcardAnswerNormalization.swift`.
- `**Features/Hangman/**` — `HangmanGameView.swift`.
- `**Features/Grammar/**` — `GrammarQuizView.swift`, `SentenceTemplate.swift`, `GrammarRule.swift` (A1 tenses / cloze).
- `**Features/CityMap/**` — `CityMapView.swift`, `VintagePaperBackground.swift`, `BakeryScenarioEngine.swift`, `SimpleLifeBakeryDialogueView.swift` (CityWalk map + bakery dialogue scene).
- `**Features/Vocabulary/**` — `VocabularyWord.swift`, `DataSeeder.swift`, `LocalSeeder.swift` (SwiftData model + seeding).
- `**Services/**` — `AudioService.swift`, `SyncService.swift`.
- **Package root** — `LearnHappyGermanApp.swift`, assets, previews.

### Data next to the `.xcodeproj`

- `**Data/german_vocabulary.json`** / `**Data/grammar_rules.json`** — bundled via the app target’s **Copy Bundle Resources** (file references to `../Data/…`).
- `Resources/README.md` — bundle asset notes.

## Unit tests (`LearnHappyGerman/LearnHappyGermanTests/`)

- `LearnHappyGermanTests.swift` — default XCTest template / harness entry.
- `**Features/Flashcards/`** — `FlashcardRegressionTests.swift`.
- `**Features/Hangman/`** — `HangmanLogicTests.swift`.
- `**Features/Grammar/**` — `GrammarQuizTests.swift`.
- `**Features/CityMap/**` — `BakeryScenarioTests.swift`.
- `**Features/Vocabulary/**` — `VocabularyWordTests`, `VocabularyDataIntegrityTests`, `VocabularySymmetryLayoutTests`, `VocabularyA2FetchPerformanceTests`.
- `**Features/Services/**` — `AudioServiceTests`, `SyncServiceTests`.

## Quality gate

- `Scripts/check_integrity.sh` — SwiftLint + `Scripts/audit_data.swift` + `xcodebuild test`.
- `Scripts/pipeline.sh` — CI-style gate with fast-path; appends summaries to `Documentation/MEMORY.md`.

Last updated: 2026-05-02 (Rejuvenated Parchment: `Theme.Colors` refresh, `vintageScreenBackground` = tiled `paper_texture`, `VintagePaperBackground.swift` shared layer)