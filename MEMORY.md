# MEMORY

Persistent log for errors, root causes, and prevention rules to avoid regression.

## Usage

- Review before starting any task.
- Add entries when a bug, failed test, or validation issue is discovered.
- Record concrete prevention rules from each incident.

## Entry Template

### [YYYY-MM-DD] 

- **Feature/Area:**
- **Symptom/Error:**
- **Root Cause:**
- **Fix Applied:**
- **Prevention Rule(s):**
  - Rule 1
- **Validation Evidence:** (unit test, UI validation, manual steps)

## Incident Log



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

### [2026-04-07] SwiftData `ModelContainer` init failure / fatalError

- **Feature/Area:** SwiftData schema (`VocabularyWord`, `GrammarRule`, store configuration).
- **Symptom/Error:** App dies in `LearnHappyGermanApp` when creating `ModelContainer` (same line as `fatalError` / store open).
- **Root Cause:** Combination of fragile pieces: `#Index` with enum-heavy models, optional persisted enum (`CEFRLevel?`) on `GrammarRule`, default store path reusing a DB from earlier incompatible schema versions, and relationship wiring.
- **Fix Applied:** Removed `#Index` from `VocabularyWord`; replaced `applicableLevel` with stored `applicableLevelCode: String?` plus `applicableLevel` computed accessor; use explicit Application Support URL `learnhappygerman-v8.store`; try persistent container then fall back to in-memory with console logging; `fatalError` only if both fail.
- **Prevention Rule(s):**
  - Prefer plain `String` (or `Int`) for persisted optional “enum-like” fields until SwiftData support is verified.
  - Bump versioned store filename when making breaking schema changes during development.
  - Avoid `#Index` until the model set is stable; enums and indexes interact badly (see composite index errors).
- **Validation Evidence:** `xcodebuild` build succeeded; run on simulator and confirm console: no persistent error, or fallback message then app runs.

### [2026-04-07] Bundled data ingestion (`LocalSeeder`)

- **Feature/Area:** Data ingestion engine (`BundledData.json` → SwiftData).
- **Symptom/Error:** N/A (baseline run after implementation).
- **Observability:** Expected counts from bundled payload v1: **7 words**, **1 grammar rule** (see `LearnHappyGerman/LearnHappyGerman/BundledData.json`). After a successful run on device/simulator, the app appends the same figures (plus timestamp) to `Application Support/.../MEMORY_ingestion_appendix.md` (copy that block here if it differs).
- **Human Takeover:** Shown when `BundledData.json` is missing, invalid JSON, validation fails (e.g. noun without article, unknown `level`, empty `exampleSentences`), or save fails.
- **Prevention Rule(s):**
  - Keep `BundledData.json` valid JSON; `level` must be `A1`…`C2`; `article` is `der`/`die`/`das`/`none`; `category` is a free-form string (e.g. `Noun`).
  - Grammar rules require non-empty `exampleSentences` arrays.
- **Validation Evidence:** `xcodebuild` build succeeded; run app once with fresh install and confirm lobby + flashcards; check console for `IngestionAudit:` path.

### [2026-04-07] SyncService remote merge + evaluator test

- **Feature/Area:** `SyncService` placeholder (`SyncService.swift`, `SyncServiceTests.swift`).
- **Behavior:** Merge key `(germanWord, level)` as strings; remote updates change editorial fields; `isMastered` preserved on update.
- **Validation Evidence:** `SyncServiceTests.testRemoteUpdatePreservesIsMastered` passes when run on a concrete simulator destination.

### [2026-04-07] Planner schema: indexed strings + UUID vocabulary

- **Feature/Area:** SwiftData models (`VocabularyWord`, `GrammarRule`), `BundledData.json`, `learnhappygerman-v9.store`.
- **Change:** `VocabularyWord` uses `@Attribute(.unique) id: UUID`, `#Index` on `germanWord` and `level` (`String`), optional `article` (`String?`), `category` (`String`), `version`. `GrammarRule` uses `exampleSentences: [String]` and `level: String` (no vocabulary relationship). `CEFRLevel` remains a non-persisted enum for lobby routing.
- **Prevention Rule(s):** Bump the versioned store filename when breaking schema changes; keep two `BundledData.json` copies in sync if both exist under the app tree.
- **Validation Evidence:** `xcodebuild -scheme LearnHappyGerman -destination 'generic/platform=iOS Simulator' build` succeeded.

### [2026-04-07] Evaluator: data integrity + symmetry tests

- **Feature/Area:** `VocabularyDataIntegrityTests`, `VocabularySymmetryLayoutTests`, `Theme.VocabularyGrandBudapest`, `FlashcardView`.
- **Behavior:** Tests assert every seeded noun has a non-empty der/die/das article, every row has `A1`–`C2` level, and `DataSeeder.seedIfNeeded` does not duplicate rows when invoked twice. `FlashcardView` wraps the main column in `Theme.VocabularyGrandBudapest.symmetricContent` (same as `wesSymmetricLayout`).
- **Validation Evidence:** `xcodebuild` `build-for-testing` for generic iOS Simulator succeeded.

### [2026-04-07] Generator: `initial_data.json` (30 A1 words)

- **Feature/Area:** `LearnHappyGerman/initial_data.json`, `VocabularyWord.requiresGermanArticle`, `FlashcardView` expected answers.
- **Behavior:** Bundle JSON lists 30 `A1` rows with UUID `id`, `article`, thematic `category` (`Daily Life`, `Activities`, `Travel`, …, `Verb`). `VocabularyWord.categoriesWithoutArticle` treats `Verb`/`Adjective`/… as lemma types without der/die/das; thematic buckets require articles. `testInitialDataJSONPassesArticleAndLevelIntegrity` loads the file from the host app bundle.
- **Validation Evidence:** `VocabularyDataIntegrityTests` suite passed on iOS Simulator (iPhone 16).

### [2026-04-07] `initial_data.json` merged at launch

- **Symptom:** A1 flashcards only showed apple/book because `BundledData.json` listed only two A1 words; `initial_data.json` was never imported.
- **Fix:** `LocalSeeder.mergeInitialDataFromBundle()` + `LearnHappyGermanApp.mergeInitialDataFromBundle` after bundled import / legacy paths; idempotent on `(germanWord, level)`.
- **Prevention Rule:** Any new corpus file must be wired into bootstrap, not only added to the bundle.