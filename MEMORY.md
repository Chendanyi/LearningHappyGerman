# MEMORY

Persistent log for errors, root causes, and prevention rules to avoid regression.

## Usage
- Review before starting any task.
- Add entries when a bug, failed test, or validation issue is discovered.
- Record concrete prevention rules from each incident.

## Entry Template

### [YYYY-MM-DD] <Short Title>
- **Feature/Area:**
- **Symptom/Error:**
- **Root Cause:**
- **Fix Applied:**
- **Prevention Rule(s):**
  - Rule 1
- **Validation Evidence:** (unit test, UI validation, manual steps)

## Incident Log
<!-- Add new incident entries below -->
# MEMORY

Persistent engineering memory to reduce repeated mistakes and regressions.

## How to Use
- Read this file before starting any implementation task.
- Add an entry whenever a bug, failure, or recurring issue is found.
- Keep entries concise and action-oriented.
- Convert repeated patterns into prevention rules.

## Entry Template

### [YYYY-MM-DD] Short Title
- **Area:** (feature/module)
- **Symptom:** What failed and how it appeared
- **Root cause:** Why it happened
- **Fix applied:** What was changed
- **Prevention rule:** Rule to avoid recurrence
- **Validation:** How the fix was verified (unit/UI/manual)

## Prevention Rules (Living List)
- Add global guardrails discovered from incidents here.
- Promote high-frequency errors into explicit workflow checks.

## Incident Log
<!-- Add new entries below this line -->
# MEMORY - Regression Prevention Log

Persistent record of failures, root causes, and prevention rules.
Update this file whenever a bug, failed test, or validation issue is discovered.

## How To Use

- Add one entry per distinct issue.
- Keep root cause factual and specific.
- Add at least one prevention rule that can be applied in future tasks.
- Reference related TODO item IDs when relevant.

## Entry Template

### [ID] Short Issue Title
- **Date:**
- **Feature:** Flashcards | Dice Game | AI Dialogue | Cross-cutting
- **Related TODO:**
- **Symptom/Error:**
- **Root Cause:**
- **Fix Applied:**
- **Prevention Rule(s):**
  - Rule 1
  - Rule 2

---

## Prevention Baseline Rules

- Validate acceptance criteria before writing implementation code.
- Keep data model changes synchronized with UI state updates.
- Add or update at least one test when fixing a bug.
- Re-run focused tests after each significant change.
- Do not close a TODO item until Evaluator confirms validation.

---

## Issue History

<!-- Add new entries below this line -->

### [AUDIT-2026-04-06] MainLobbyView Visual and Logic Audit
- **Date:** 2026-04-06
- **Feature:** Cross-cutting (Lobby + Navigation)
- **Related TODO:** App Navigation Architecture / Design System
- **Symptom/Error:** Lobby header used directional spacing (`top` on bell, `bottom` on subtitle), which breaks strict symmetry guidance.
- **Root Cause:** Vertical rhythm was tuned with element-specific padding instead of a single symmetric stack spacing system.
- **Fix Applied:** Removed directional paddings and kept consistent `VStack(spacing: 16)` to preserve centered composition.
- **Prevention Rule(s):**
  - For symmetric hero sections, avoid per-element directional padding; prefer one parent stack spacing rule.
  - If directional padding is required, pair it with equivalent opposite-side compensation and document why.
  - During review, check for `.padding(.top|.bottom|.leading|.trailing)` on individual header elements.
- **Validation Evidence:** 
  - Visual check: Lobby content remains centered and balanced.
  - State check: tapping `B1` sets `AppState.currentLevel = .b1` and hallway displays `Current Level: B1`.
  - Color check: `MainLobbyView` uses `Theme.Colors.mendlsPink`, `Theme.Colors.lobbyBoyPurple`, and `Theme.Colors.societyBlue`, matching `Theme.swift` hex values (`#F8C1C1`, `#6D4C7D`, `#A7C7E7`).
  - Scope note: vocabulary filtering is ready via `AppState.currentLevel`; module-level SwiftData query filtering is pending classroom implementation.
