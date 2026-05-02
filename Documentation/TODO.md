# TODO

Hierarchical checklist by feature and execution phase.

## Harness Rule - Done Gate

- Before marking any feature task as DONE, run `./check_integrity.sh` (runs `Scripts/check_integrity.sh` from repo root).
- If either SwiftLint or `swift test` fails, task status must remain in-progress.

## Nightly — Blocked (needs human)

Autonomous agents must **not** change `Package.swift`, run `brew install`, or use `sudo` without explicit confirmation. Log proposed dependency or environment changes here as **Blocked** until approved.

- (none)

## Prioritized Roadmap (Planner)

- Phase 1: Foundation. SwiftData Model for `VocabularyWord` including `level` and `article` properties.
- Phase 2: The Lobby. Symmetrical Main Entrance UI with Level Selection.
- Phase 3: Core Flashcards. Basic card-flip logic with "Budapest" styling.
- Phase 4: The Harness. Implement Evaluator tests to ensure A1 words do not leak into C2 views.
- Phase 5: Minigames. Implement Dice Game and Hangman logic.

## Current Priority - App Navigation Architecture (Planner)

- Define "The Lobby" as mandatory app entrance
  - First screen is CEFR check-in (`A1` to `C2`)
  - Use Hotel Check-in metaphor in centered composition
  - Block feature-room access until level is selected
- Define "Feature Rooms" as module door hub
  - Flashcards: Article + Noun matching
  - Tense Training: Fill-in-the-blank + grammar feedback
  - Sentence Dice: Randomized SVO generator
  - AI Voice Dialogue: Scenario chat (Bakery, Station)
  - Hangman: Doodle-style word guessing
- Define global state management contract
  - Introduce `UserSession` as global selected-level source of truth
  - Ensure all modules query SwiftData using selected CEFR level
  - Prevent per-module duplicate level state
- Deliver Planner artifact
  - Keep navigation spec in `NAVIGATION_ARCHITECTURE.md`

## Current Priority - Cross-Feature Design System (Planner)

- Requirements freeze for visual language and UI consistency
  - Color Palette (see `Theme.swift` — Rejuvenated Parchment)
    - Global screen background: tiled `paper_texture` via `vintageScreenBackground()`
    - `lobbyBoyPurple` = `#2F2A26` (primary ink)
    - `secondaryText` = `#4A443E`, `deepBrown` = `#8B6B4F` (tertiary / hints)
    - `accentPrimary` = `#C96A5A` (map hotspots only); `accentUI` = `#B05A4A` (buttons / general UI)
    - `pastelYellow` = `#D7C39A` (map road wash / accents), `softBrown` = `#A1866F` (optional accents)
    - `cardFill` = `#EDD9B4` (`vintageCard` @ 0.9 opacity), `cardHighlight` = `#F7F0E3` (inputs / inner surfaces)
    - `vintageCard` border = `deepBrown`; shadow = `#5C4B37` @ 0.15; `societyBlue` = `#BFB6A8` (standard UI borders)
    - `mossGreen` = `#7A8F7A` (success); `accentSecondary` = `#D98C7A`; `cardHighlight` = `#EFE2CD`
  - Typography
    - Rounded minimalist baseline
    - Fallback: `design: .rounded`, `weight: .medium`
  - Layout Rule
    - Enforce centered composition and strict symmetry in every view
  - Doodle Style
    - Thin-stroke icons only (`SF Symbols` with `.ultraLight`) or custom SVG doodles
  - Deliverable
    - `Theme.swift` created and adopted as the canonical design token source

## Flashcards

- Planner
  - Requirements
  - Roadmap
- Generator
  - SwiftUI implementation
  - SwiftData integration
- Evaluator
  - Unit tests
  - UI validation

## Dice Game

- Planner
  - Requirements
  - Roadmap
- Generator
  - SwiftUI implementation
  - SwiftData integration
- Evaluator
  - Unit tests
  - UI validation

## AI Dialogue

- Planner
  - Requirements
  - Roadmap
- Generator
  - SwiftUI implementation
  - SwiftData integration
- Evaluator
  - Unit tests
  - UI validation