# LearningHappyGerman

SwiftUI + SwiftData learning app structured around a lobby-and-classroom experience.

## What It Does
- Shows a Main Entrance lobby (`MainLobbyView`) for CEFR level check-in (`A1` to `C2`).
- Uses a symmetrical "Hotel Concierge Board" composition for level selection.
- Applies shared design tokens from `Theme.swift` (palette, typography, symmetry, icon style).

## Project Layout
- `MainLobbyView.swift`: Main Entrance (Lobby) UI and level-selection interactions.
- `Theme.swift`: App design tokens and layout/icon helpers.
- `VocabularyWord.swift`: SwiftData vocabulary model and CEFR/article/category definitions.
- `DataSeeder.swift`: A1-C2 import and seed-if-needed logic.
- `VocabularyWordTests.swift`: Evaluator guard test for noun/article validity.
- `AGENTS.md` / `TODO.md` / `MEMORY.md`: Planner-Generator-Evaluator process docs.

Last updated: 2026-04-06
