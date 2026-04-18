# ProjectMap

## Root Files

- `MainLobbyView.swift` - Lobby entrance UI with CEFR selector and first-run import progress bar.
- `FlashcardView.swift` - First classroom screen with answer validation (shared German normalization), centered feedback/`Next` column, feedback animation, and `AudioService` TTS (de-DE) with speaker replay.
- `AudioService.swift` - `AVSpeechSynthesizer` German speech, mixed audio session, coalesced manual replay.
- `HangmanGameView.swift` - Hangman classroom with Mendl's cake-box visual, symmetric word slots, and letter keyboard.
- `GrammarQuizView.swift` / `SentenceTemplate.swift` (nested `LearnHappyGerman/LearnHappyGerman/`) - A1 present-tense cloze; Hallway **Tenses**; MendlsPink + SocietyBlue.
- `SimpleLifeBakeryDialogueView.swift` / `BakeryScenarioEngine.swift` - A1 multi-turn bakery dialogue; Hallway **AI Dialogue**.
- `GermanFlashcardAnswerNormalization.swift` - Typed-answer comparison helper (de_DE folding, ß→`ss`).
- `Theme.swift` - Shared color, typography, symmetry, and icon styling utilities.
- `VocabularyWord.swift` - SwiftData vocabulary model (UUID `id`, `version`, indexed `germanWord`/`level` strings, optional `article`, `category` string) and `CEFRLevel` for UI only.
- `GrammarRule.swift` - Grammar rules (`title`, `explanation`, `level`, `exampleSentences`).
- `HYBRID_DATA_ARCHITECTURE.md` - Planner notes on vocabulary + grammar SwiftData layout.
- `DataSeeder.swift` - Seed pipeline for CEFR A1-C2 data imports; background bulk import with batched saves and upsert.
- `vocab_processor.py` - External CSV/JSON -> minified `full_vocabulary.json` transformer for CEFR imports.
- `LocalSeeder.swift` - First-launch ingestion from `BundledData.json`; merges `full_vocabulary.json` (preferred large corpus) and `initial_data.json` idempotently on each bootstrap path; audit log for `MEMORY.md`.
- `BundledData.json` (under `LearnHappyGerman/` and nested app folder) - Bundled vocabulary and grammar rules JSON (`exampleSentences` on rules).
- `initial_data.json` - 30 A1 words (UUID `id`, `article`, thematic `category`); shipped in app bundle; covered by `VocabularyDataIntegrityTests`.
- `full_vocabulary.json` - Generated full corpus payload (`{"version":1,"words":[...]}`) for large A1-C2 ingestion; **500** A2 lemmas with `pluralSuffix` + `exampleSentence` via `scripts/build_a2_500.py`; `scripts/audit_level_overlap.py` ensures no B1 lemma duplicates A1/A2.
- `SyncService.swift` - Remote JSON merge placeholder; `SyncServiceTests.swift` - remote update preserves mastery.
- `VocabularyWordTests.swift` - Noun/article validity guard.
- `VocabularyDataIntegrityTests.swift` - Seeded nouns + CEFR levels; seed-if-needed idempotency.
- `VocabularySymmetryLayoutTests.swift` - Grand Budapest theme symmetry contract for vocabulary screens.
- `FlashcardRegressionTests.swift` - A1 filter integration after `initial_data` merge; umlaut/ß normalization tests.
- `AudioServiceTests.swift` - Smoke tests for TTS helpers (no crash on empty or sample phrases).
- `NAVIGATION_ARCHITECTURE.md` - Planner navigation specification.
- `AGENTS.md` - Persona loop, architecture guidelines, and **Nightly Autonomous Protocol** (daily branch, allowlist: Unix tools + `swift`/`xcodebuild`/`xcrun`, non-blocking policy for unlisted essential commands with `MEMORY.md` logging, strict sudo/brew/`Package.swift` red lines).
- `TODO.md` - Prioritized roadmap and feature checklists.
- `MEMORY.md` - Regression-prevention log; **Morning Brief** sections (`# Morning Brief YYYY-MM-DD`) appended by Evaluator at end of autonomous sessions.
- `.cursorrules` - Pre-task workflow constraints.
- `.swiftlint.yml` - Strict lint policy, naming rules, and symmetry exception checks.
- `check_integrity.sh` - Local quality gate script for lint + tests.
- `scripts/audit_data.swift` - Standalone `full_vocabulary.json` audit (nouns + German lemma characters).
- `Package.swift` / `Package.resolved` - SPM tooling package (swift-snapshot-testing) for future visual regression tests; app remains Xcode-based.