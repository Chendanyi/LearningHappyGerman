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

## Verification Mechanism (Data + UI)

- **Bundled vocabulary audit:** `scripts/audit_data.swift` validates every `full_vocabulary.json` found under `LearnHappyGerman/` (app bundle copy and repo-level copy). It runs in `./scripts/pipeline.sh` **before** the fast-path / full-test split, so JSON-only commits still must pass data rules.
- **Runtime integrity:** `VocabularyDataIntegrityTests` and grammar regressions remain the SwiftData-level gate inside the test suite.

## Break Glass Protocol (SwiftUI Symmetry)

- If an Agent is **stuck in a loop** trying to satisfy a **SwiftLint symmetry warning** (for example `symmetry_exception_marker` or repeated layout tweaks with no stable pass), it **must stop** and ask the user for an explicit **Design Exception** (what to allow, which screen, and why) instead of guessing further padding or offsets.
- After approval, document the exception in code with `// SYMMETRY-EXCEPTION: <reason>` on the relevant directional padding (see `.swiftlint.yml`), or adjust the lint rule via a deliberate project decision recorded in `MEMORY.md`.

## Zero-Failure Merge Policy

### Generator Constraint

- Merging code into `main` is forbidden if `./check_integrity.sh` fails.
- A passing integrity run is mandatory before any merge decision.

### Evaluator Veto Power

- Evaluator has veto power over release readiness.
- If any UI component violates symmetry or a German grammar test fails, Evaluator must trigger an automatic revert of the last commit.

### Test Requirements

- Grammar Regression: whenever a CEFR level is added or updated (`A1`...`C2`), tests must verify the `VocabularyWord` Noun + Article rule still holds.
- Symmetry Test: UI tests should verify `MainLobbyView` key elements remain centered.
- Memory Logging: every pipeline run (pass or fail) must append a summary line to `MEMORY.md`.

### Pre-commit Logic

- Before every git commit, simulate a pre-commit hook by running the full test suite.
- Record the run outcome in `MEMORY.md` with explicit `Pass`/`Fail` status.
- No agent is allowed to bypass the pre-commit hook.
- Every commit must be a **Verified Commit**.

## Git Workflow Refinement

- For every new feature (for example, `A1 Flashcards`), create and use a temporary feature branch.
- After implementation, Evaluator must run `./check_integrity.sh` before merge or release decisions.
- If integrity check passes, append a `Verified` badge marker to the commit message.
- Standard commit format for passed checks: `<type>: <short description> [Verified]` (example: `feat: add A1 flashcards flow [Verified]`).
- If integrity check fails, Agent must analyze the error, log the failure pattern in `MEMORY.md`, and fix it immediately.
- Do not ask the user for lint/test failure help until three autonomous fix attempts have been made and documented.

## Portability and Privacy Guardrails (All Personas)

- Do not hardcode machine-specific paths in project code or scripts.
- Prefer portable detection (`command -v`, environment variables, dynamic runtime discovery).
- Do not commit personal or sensitive local identifiers (home paths, usernames, device IDs, private tokens, or machine-specific metadata).

## Lint Guardrail Overrides

- Root lint policy: `.swiftlint.yml` (main code stays strict; `force_unwrapping` is an error).
- Grammar complexity override: `LearnHappyGerman/GrammarEngine/.swiftlint.yml` (`cyclomatic_complexity` warning 15, error 20).
- Test force-unwrap override:
  - `LearnHappyGerman/LearnHappyGermanTests/.swiftlint.yml`
  - `LearnHappyGerman/LearnHappyGermanUITests/.swiftlint.yml`
  - In tests, `force_unwrapping` is downgraded to warning for concise fixture setup.

## Snapshot Testing (Prepared)

- Root `Package.swift` declares the **pointfreeco/swift-snapshot-testing** dependency and a small `LearningHappyGermanSnapshots` library target for future visual regression tests (Lobby and classroom symmetry). The production app is still built from `LearnHappyGerman/LearnHappyGerman.xcodeproj`; resolve SPM with `swift package resolve` at the repo root when adding snapshot tests.