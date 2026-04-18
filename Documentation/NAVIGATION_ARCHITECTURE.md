# App Navigation Architecture

Planner-defined navigation structure and state contract for the learning app.

## 1) Main Entrance - "The Lobby"

### Goal
The Lobby is the app's central dashboard and first-screen experience.

### UI Metaphor
- Present CEFR level selection (`A1` to `C2`) as a "Hotel Check-in" flow.
- Visual language:
  - Centered concierge/check-in card
  - Level options displayed as check-in tickets/keys
  - Confirmation action framed as "Enter Hotel"

### Required Behavior
- User cannot enter feature modules until a CEFR level is selected.
- Selected level is persisted in session state and reflected globally.
- Lobby remains re-enterable from all modules (home/back to lobby path).

## 2) Feature Rooms - "The Classrooms"

After level selection, the app transitions to a Rooms screen where each module is represented as a "Room Door".

### Room Doors (Modules)
1. **Flashcards**
   - Learning mechanic: `Article + Noun` matching.
2. **Tense Training**
   - Learning mechanic: fill-in-the-blank with detailed grammar feedback.
3. **Sentence Dice**
   - Learning mechanic: randomized SVO (Subject-Verb-Object) generator.
4. **AI Voice Dialogue**
   - Learning mechanic: scenario-based chat (Bakery, Station).
5. **Hangman**
   - Learning mechanic: doodle-style word guessing game.

### Navigation Rule
- All Room Doors receive vocabulary/content filtered by current CEFR level from session state.

## 3) State Management Contract

Use a global `UserSession` class as single source of truth for selected level.

### Responsibilities
- Hold currently selected CEFR level (`A1`...`C2`).
- Expose state globally so every module can resolve the active vocabulary scope.
- Provide controlled level updates from Lobby check-in only.
- Trigger reactive updates when level changes.

### Data Access Rule
- All module data queries (SwiftData fetches) must include CEFR level from `UserSession`.
- No module should hardcode level filters or maintain separate level state.

## 4) Screen Map

1. `LobbyView` (check-in, level selection)
2. `RoomsView` (module door hub)
3. Module views:
   - `FlashcardsView`
   - `TenseTrainingView`
   - `SentenceDiceView`
   - `AIVoiceDialogueView`
   - `HangmanView`

Primary flow:
- Launch -> Lobby -> Rooms -> Module -> Rooms/Lobby

## 5) Acceptance Criteria (Planner)

- Lobby is the first visible screen.
- CEFR selection is mandatory before entering Rooms.
- Rooms screen shows exactly five module doors.
- Each module consumes CEFR level from `UserSession`.
- Level change in Lobby immediately affects module vocabulary scope.
