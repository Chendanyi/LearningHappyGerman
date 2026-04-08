# ProjectMap

## Root Files
- `MainLobbyView.swift` - Lobby entrance UI with CEFR selector.
- `FlashcardView.swift` - First classroom screen with answer validation (shared German normalization), centered feedback/`Next` column, and feedback animation.
- `GermanFlashcardAnswerNormalization.swift` - Typed-answer comparison helper (de_DE folding, ß→`ss`).
- `Theme.swift` - Shared color, typography, symmetry, and icon styling utilities.
- `VocabularyWord.swift` - SwiftData vocabulary model (UUID `id`, `version`, indexed `germanWord`/`level` strings, optional `article`, `category` string) and `CEFRLevel` for UI only.
- `GrammarRule.swift` - Grammar rules (`title`, `explanation`, `level`, `exampleSentences`).
- `HYBRID_DATA_ARCHITECTURE.md` - Planner notes on vocabulary + grammar SwiftData layout.
- `DataSeeder.swift` - Seed pipeline for CEFR A1-C2 data imports (fallback when bundled import did not populate the store).
- `vocab_processor.py` - External CSV/JSON -> minified `full_vocabulary.json` transformer for CEFR imports.
- `LocalSeeder.swift` - First-launch ingestion from `BundledData.json`; merges `full_vocabulary.json` (preferred large corpus) and `initial_data.json` idempotently on each bootstrap path; audit log for `MEMORY.md`.
- `BundledData.json` (under `LearnHappyGerman/` and nested app folder) - Bundled vocabulary and grammar rules JSON (`exampleSentences` on rules).
- `initial_data.json` - 30 A1 words (UUID `id`, `article`, thematic `category`); shipped in app bundle; covered by `VocabularyDataIntegrityTests`.
- `full_vocabulary.json` - Generated full corpus payload (`{"version":1,"words":[...]}`) for large A1-C2 ingestion.
- `SyncService.swift` - Remote JSON merge placeholder; `SyncServiceTests.swift` - remote update preserves mastery.
- `VocabularyWordTests.swift` - Noun/article validity guard.
- `VocabularyDataIntegrityTests.swift` - Seeded nouns + CEFR levels; seed-if-needed idempotency.
- `VocabularySymmetryLayoutTests.swift` - Grand Budapest theme symmetry contract for vocabulary screens.
- `FlashcardRegressionTests.swift` - A1 filter integration after `initial_data` merge; umlaut/ß normalization tests.
- `NAVIGATION_ARCHITECTURE.md` - Planner navigation specification.
- `AGENTS.md` - Persona loop and architecture guidelines.
- `TODO.md` - Prioritized roadmap and feature checklists.
- `MEMORY.md` - Regression-prevention log.
- `.cursorrules` - Pre-task workflow constraints.
- `.swiftlint.yml` - Strict lint policy, naming rules, and symmetry exception checks.
- `check_integrity.sh` - Local quality gate script for lint + tests.
