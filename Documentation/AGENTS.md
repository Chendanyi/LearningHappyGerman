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
- Feed regression learnings into `Documentation/MEMORY.md`.
- At the **end of each autonomous session**, append a **Morning Brief** to `Documentation/MEMORY.md` (see **Morning Brief (Evaluator)** below).

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

- Global style follows a **vintage hand-drawn illustrated map** inspired by *The Grand Budapest Hotel*.
- Visual baseline:
  - Background: tiled `paper_texture` on all main screens (`vintageScreenBackground()`); no full-screen gradient behind content.
  - Typography: serif-forward (Playfair/Libre/Cormorant style), uppercase titles, slight title tracking (+2% to +5%).
  - Text colors: primary `#2F2A26`, secondary `#4A443E`, tertiary/hints `#8B6B4F` (`deepBrown`); never pure black.
  - Accents: `#C96A5A` (`accentPrimary`) **map-only** (hotspots); `#B05A4A` (`accentUI`) for buttons and general UI; `#D98C7A` (`accentSecondary`) where a second accent is needed.
  - Cards: fill `#EDD9B4` (`cardFill`) at 0.9 opacity; border `#8B6B4F` (`deepBrown`); shadow `#5C4B37` @ 0.15. Standard control strokes use `#BFB6A8` (`societyBlue`).
  - Shadows: soft and minimal only (`rgba(0,0,0,0.08)` with tiny offset / blur).
  - Layout: generous negative space, refined asymmetry preferred over rigid grid repetition.
  - Avoid: highly saturated colors, thick borders, heavy modern shadows/effects.

## Required Loop Per Feature

For every feature, execute in order:

1. Planner
2. Generator
3. Evaluator

## Verification Mechanism (Data + UI)

- **Bundled vocabulary audit:** `Scripts/audit_data.swift` validates **`Data/german_vocabulary.json`**. It runs in `./Scripts/pipeline.sh` **before** the fast-path / full-test split, so JSON-only commits still must pass data rules.
- **Runtime integrity:** `VocabularyDataIntegrityTests` and grammar regressions remain the SwiftData-level gate inside the test suite.

## Break Glass Protocol (SwiftUI Symmetry)

- If an Agent is **stuck in a loop** trying to satisfy a **SwiftLint symmetry warning** (for example `symmetry_exception_marker` or repeated layout tweaks with no stable pass), it **must stop** and ask the user for an explicit **Design Exception** (what to allow, which screen, and why) instead of guessing further padding or offsets.
- After approval, document the exception in code with `// SYMMETRY-EXCEPTION: <reason>` on the relevant directional padding (see `.swiftlint.yml`), or adjust the lint rule via a deliberate project decision recorded in `Documentation/MEMORY.md`.

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
- Memory Logging: every pipeline run (pass or fail) must append a summary line to `Documentation/MEMORY.md`.

### Pre-commit Logic

- Before every git commit, simulate a pre-commit hook by running the full test suite.
- Record the run outcome in `Documentation/MEMORY.md` with explicit `Pass`/`Fail` status.
- No agent is allowed to bypass the pre-commit hook.
- Every commit must be a **Verified Commit**.

## Git Workflow Refinement

- For every new feature (for example, `A1 Flashcards`), create and use a temporary feature branch.
- After implementation, Evaluator must run `./check_integrity.sh` before merge or release decisions.
- If integrity check passes, append a `Verified` badge marker to the commit message.
- Standard commit format for passed checks: `<type>: <short description> [Verified]` (example: `feat: add A1 flashcards flow [Verified]`).
- If integrity check fails, Agent must analyze the error, log the failure pattern in `Documentation/MEMORY.md`, and fix it immediately.
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

## Nightly Autonomous Protocol (Planner)

### Daily branching

- **Before** starting any nightly (or autonomous batch) task, create a temporary branch: `nightly/YYYY-MM-DD` (example: `nightly/2026-04-09`). Use the **authoritative calendar date** for the run.
- Commit all progress on that branch only for the duration of the batch.
- **Never** merge to `main` (or any protected integration branch) without **explicit human review** and a normal PR/integrity pass.

### Permission scope (autonomous work)

Agents may **read and write** within these areas (this repository’s layout):

- **Source:** application Swift sources under `LearnHappyGerman/` (including `LearnHappyGerman/LearnHappyGerman/`).
- **Tests:** `LearnHappyGerman/LearnHappyGermanTests/`, `LearnHappyGerman/LearnHappyGermanUITests/`, and root-level `*Tests.swift` files co-located with the app tree where the project already places them.
- **Resources:** bundled JSON, assets, and copy under `LearnHappyGerman/` (for example `*.json`, `Assets.xcassets`, `Preview Content`).

Agents may **execute** for validation:

- `./Scripts/pipeline.sh`
- `./check_integrity.sh` (when present)
- `xcodebuild` (build/test) against the `LearnHappyGerman` scheme and available simulators, consistent with existing scripts.

### Nightly allowlist (pre-authorized)

To reduce workflow interruptions, the following are **pre-authorized** for nightly/autonomous batches (still subject to **Manual authorization gate** red lines below).

**Standard Unix utilities** (use `rm` only inside project **source/resource** paths listed under *Permission scope*; do not delete arbitrary user files outside the repo):

- `mkdir`, `cp`, `mv`, `rm`, `find`, `grep`, `cat`, `chmod` (e.g. `chmod +x` for scripts)

**Build and Apple toolchain:**

- `swift` (including `swift Scripts/…` for repo scripts; do not use SwiftPM to add or change dependencies—see red lines)
- `xcodebuild`
- `xcrun` (including `simctl` and other subcommands invoked via `xcrun`)

### Command not on the allowlist (non-blocking policy)

If a command is **not** listed above but appears **essential** for the task (for example a specific **`git`** invocation):

1. **Do not stop** the batch solely because the command is unlisted.
2. **Log** the exact command line and short rationale in `Documentation/MEMORY.md` (dated entry or under the session’s notes).
3. **Prefer** an alternative path using only allowlisted commands when one exists.
4. **Only** if no alternative exists **and** the task is **Critical** to the batch: mark the item **Blocked** in `Documentation/TODO.md` (see **Nightly — Blocked**), note it in `Documentation/MEMORY.md`, and **continue** with the next independent batch item.

### Manual authorization gate

Without **explicit human confirmation**, agents are **forbidden** to:

- Run `brew install` or other package-manager installs that change the machine environment.
- Run `sudo` or any command requiring elevated privileges.
- **Modify `Package.swift`** to add or upgrade dependencies (including new SPM packages).

**Strict red-line:** `sudo`, `brew` (install/upgrade), and **any** `Package.swift` modification that adds or bumps dependencies remain **absolute**—no exceptions via the non-blocking policy.

If a new library or tool is needed, add a **Blocked** line item under **Nightly — Blocked (needs human)** in `Documentation/TODO.md` with a short rationale and link or package name; do not change `Package.swift` autonomously.

### Nightly batch processing

When the user provides a **Nightly Batch Requirement** (ordered list of tasks):

1. Process tasks **sequentially** in the given order.
2. If a task **fails**, append a concise entry to `Documentation/MEMORY.md` (symptom, root cause if known, next step) and **continue** with the **next independent** task. Do not halt the entire batch for one failure unless the user scope says otherwise.
3. Dependent tasks that require a failed prerequisite should be **skipped** with a note in `Documentation/MEMORY.md`, not attempted blindly.

## Morning Brief (Evaluator)

At the **end** of an autonomous session (after commits on `nightly/YYYY-MM-DD` or equivalent batch work), the Evaluator **must** append a new section to `Documentation/MEMORY.md` titled:

`# Morning Brief YYYY-MM-DD`

Use the **authoritative calendar date** for the run (same date as the nightly branch when applicable).

### Required fields

Summarize, with concrete examples where helpful:

| Field | Purpose |
| --- | --- |
| **Tasks Completed** | What shipped or was initialized (e.g. A2 grammar database initialized). |
| **Tests Passed** | Counts or suite names (e.g. 12/12 unit tests passed; pipeline green). |
| **Failed/Blocked** | Items not done and why (e.g. AI Voice Dialogue blocked due to missing API key). Use `(none)` if clear. |
| **Lint Status** | SwiftLint outcome; list **persistent** symmetry or other warnings that remain. Use `(none)` if clean. |

### Merge command for the human (after approval)

Do **not** merge to `main` autonomously. Provide the human with the **exact** command(s) to run **after** they approve the work (replace `nightly/YYYY-MM-DD` with the actual branch).

**Exact one-liner** (as requested for copy-paste):

```bash
git checkout main && git merge nightly/YYYY-MM-DD
```

**Recommended** (updates `main` from `origin` before merging):

```bash
git checkout main && git pull origin main && git merge nightly/YYYY-MM-DD
```

Example for a run on 9 April 2026:

```bash
git checkout main && git merge nightly/2026-04-09
```

The Morning Brief in `Documentation/MEMORY.md` must repeat the **same** branch name in the **Merge** line so the human can copy-paste without guessing.
