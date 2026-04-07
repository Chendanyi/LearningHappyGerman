# ProjectMap

## Root Files
- `MainLobbyView.swift` - Lobby entrance UI with CEFR selector.
- `FlashcardView.swift` - First classroom screen with answer validation and feedback animation.
- `Theme.swift` - Shared color, typography, symmetry, and icon styling utilities.
- `VocabularyWord.swift` - SwiftData vocabulary model (version field) and related enums.
- `GrammarRule.swift` - Grammar explanations, examples, and rules; optional link to a `VocabularyWord`.
- `HYBRID_DATA_ARCHITECTURE.md` - Planner notes on vocabulary + grammar SwiftData layout.
- `DataSeeder.swift` - Seed pipeline for CEFR A1-C2 data imports (fallback when bundled import did not populate the store).
- `LocalSeeder.swift` - First-launch ingestion from `BundledData.json`; audit log for `MEMORY.md`.
- `BundledData.json` (under `LearnHappyGerman/LearnHappyGerman/`) - Bundled vocabulary and grammar rules JSON.
- `VocabularyWordTests.swift` - Test coverage for noun/article validation rule.
- `NAVIGATION_ARCHITECTURE.md` - Planner navigation specification.
- `AGENTS.md` - Persona loop and architecture guidelines.
- `TODO.md` - Prioritized roadmap and feature checklists.
- `MEMORY.md` - Regression-prevention log.
- `.cursorrules` - Pre-task workflow constraints.
- `.swiftlint.yml` - Strict lint policy, naming rules, and symmetry exception checks.
- `check_integrity.sh` - Local quality gate script for lint + tests.
