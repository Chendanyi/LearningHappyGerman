# LearningHappyGerman

SwiftUI + SwiftData learning app structured around a lobby-and-classroom experience.

## What It Does
- Shows a Main Entrance lobby (`MainLobbyView`) for CEFR level check-in (`A1` to `C2`).
- Uses a symmetrical "Hotel Concierge Board" composition for level selection.
- Routes the Hallway "Flashcards" door to `FlashcardView` as the first classroom.
- Seeds starter CEFR vocabulary (`A1` to `C2`) on first launch if the local store is empty.
- Applies shared design tokens from `Theme.swift` (palette, typography, symmetry, icon style).
- Enforces a quality gate with SwiftLint + tests via `check_integrity.sh`.
  - Runs `swiftlint` and `xcodebuild test` for the `LearnHappyGerman` scheme.

## Project Layout
- `MainLobbyView.swift`: Main Entrance (Lobby) UI and level-selection interactions.
- `FlashcardView.swift`: First classroom with card prompt, answer input, and article-aware validation feedback.
- `Theme.swift`: App design tokens and layout/icon helpers.
- `VocabularyWord.swift`: SwiftData vocabulary model and CEFR/article/category definitions.
- `DataSeeder.swift`: A1-C2 import and seed-if-needed logic.
- `VocabularyWordTests.swift`: Evaluator guard test for noun/article validity.
- `.swiftlint.yml`: strict lint configuration and custom style/symmetry checks.
- `check_integrity.sh`: pipeline script (`swiftlint` + `swift test`) that fails fast on violations.
- `AGENTS.md` / `TODO.md` / `MEMORY.md`: Planner-Generator-Evaluator process docs.

Last updated: 2026-04-07 (quality pipeline update)
