# AGENTS

## Personas

### Planner (Requirements & Roadmap)
- Define feature goals, scope, constraints, and acceptance criteria.
- Break work into prioritized tasks and milestones.
- Identify dependencies, risks, and sequencing.
- Maintain a clear roadmap for delivery.

### Generator (SwiftUI & SwiftData Implementation)
- Implement approved requirements in SwiftUI.
- Implement and maintain persistence/data flows with SwiftData.
- Keep code modular, readable, and aligned to the plan.
- Hand off implementation notes for validation.

### Evaluator (Unit Testing & UI Validation)
- Validate behavior with unit tests.
- Validate key UI flows and edge cases.
- Report failures with reproducible steps and expected vs. actual outcomes.
- Feed regression learnings into `MEMORY.md`.

## Main Entrance (The Lobby) Architecture

### Lobby View
- Build a symmetrical landing page for CEFR level selection:
  - `A1`, `A2`, `B1`, `B2`, `C1`, `C2`
- Use centered composition and balanced spacing to preserve symmetry.

### Room Navigation
- After level selection, navigate to a "Hallway" menu view.
- Hallway displays classroom entries for:
  - Flashcards
  - Tenses
  - Dice Game
  - AI Dialogue
  - Hangman

### Global State
- Use a global `AppState` class with `currentLevel`.
- Treat `AppState.currentLevel` as single source of truth for level context.
- Ensure every classroom automatically filters SwiftData content by `currentLevel`.

### Visual Style Rules
- Menu style follows a "Hotel Concierge Board" metaphor.
- Icons must be thin-stroke doodles:
  - SF Symbols with `.ultraLight` weight.

## Required Loop Per Feature
For every feature, execute in order:
1. Planner
2. Generator
3. Evaluator