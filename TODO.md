# TODO

Hierarchical checklist by feature and execution phase.

## Prioritized Roadmap (Planner)
- [ ] Phase 1: Foundation. SwiftData Model for `VocabularyWord` including `level` and `article` properties.
- [ ] Phase 2: The Lobby. Symmetrical Main Entrance UI with Level Selection.
- [ ] Phase 3: Core Flashcards. Basic card-flip logic with "Budapest" styling.
- [ ] Phase 4: The Harness. Implement Evaluator tests to ensure A1 words do not leak into C2 views.
- [ ] Phase 5: Minigames. Implement Dice Game and Hangman logic.

## Current Priority - App Navigation Architecture (Planner)
- [ ] Define "The Lobby" as mandatory app entrance
  - [ ] First screen is CEFR check-in (`A1` to `C2`)
  - [ ] Use Hotel Check-in metaphor in centered composition
  - [ ] Block feature-room access until level is selected
- [ ] Define "Feature Rooms" as module door hub
  - [ ] Flashcards: Article + Noun matching
  - [ ] Tense Training: Fill-in-the-blank + grammar feedback
  - [ ] Sentence Dice: Randomized SVO generator
  - [ ] AI Voice Dialogue: Scenario chat (Bakery, Station)
  - [ ] Hangman: Doodle-style word guessing
- [ ] Define global state management contract
  - [ ] Introduce `UserSession` as global selected-level source of truth
  - [ ] Ensure all modules query SwiftData using selected CEFR level
  - [ ] Prevent per-module duplicate level state
- [ ] Deliver Planner artifact
  - [ ] Keep navigation spec in `NAVIGATION_ARCHITECTURE.md`

## Current Priority - Cross-Feature Design System (Planner)
- [ ] Requirements freeze for visual language and UI consistency
  - [ ] Color Palette
    - [ ] `MendlsPink` = `#F8C1C1` (main background)
    - [ ] `SocietyBlue` = `#A7C7E7` (selection/active state)
    - [ ] `LobbyBoyPurple` = `#6D4C7D` (accents/text)
    - [ ] `PastelYellow` = `#FDFD96` (article highlighting)
  - [ ] Typography
    - [ ] Rounded minimalist baseline
    - [ ] Fallback: `design: .rounded`, `weight: .medium`
  - [ ] Layout Rule
    - [ ] Enforce centered composition and strict symmetry in every view
  - [ ] Doodle Style
    - [ ] Thin-stroke icons only (`SF Symbols` with `.ultraLight`) or custom SVG doodles
  - [ ] Deliverable
    - [ ] `Theme.swift` created and adopted as the canonical design token source

## Flashcards
- [ ] Planner
  - [ ] Requirements
  - [ ] Roadmap
- [ ] Generator
  - [ ] SwiftUI implementation
  - [ ] SwiftData integration
- [ ] Evaluator
  - [ ] Unit tests
  - [ ] UI validation

## Dice Game
- [ ] Planner
  - [ ] Requirements
  - [ ] Roadmap
- [ ] Generator
  - [ ] SwiftUI implementation
  - [ ] SwiftData integration
- [ ] Evaluator
  - [ ] Unit tests
  - [ ] UI validation

## AI Dialogue
- [ ] Planner
  - [ ] Requirements
  - [ ] Roadmap
- [ ] Generator
  - [ ] SwiftUI implementation
  - [ ] SwiftData integration
- [ ] Evaluator
  - [ ] Unit tests
  - [ ] UI validation
