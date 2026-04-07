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

## Zero-Failure Merge Policy

### Generator Constraint

- Merging code into `main` is forbidden if `./check_integrity.sh` fails.
- A passing integrity run is mandatory before any merge decision.

### Evaluator Veto Power

- Evaluator has veto power over release readiness.
- If any UI component violates symmetry or a German grammar test fails, Evaluator must trigger an automatic revert of the last commit.

### Pre-commit Logic

- Before every git commit, simulate a pre-commit hook by running the full test suite.
- Record the run outcome in `MEMORY.md` with explicit `Pass`/`Fail` status.

## Portability and Privacy Guardrails (All Personas)

- Do not hardcode machine-specific paths in project code or scripts.
- Prefer portable detection (`command -v`, environment variables, dynamic runtime discovery).
- Do not commit personal or sensitive local identifiers (home paths, usernames, device IDs, private tokens, or machine-specific metadata).