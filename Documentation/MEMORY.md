# MEMORY

Persistent log for errors, root causes, and prevention rules to avoid regression.

## Usage

- Review before starting any task.
- Add entries when a bug, failed test, or validation issue is discovered.
- Record concrete prevention rules from each incident.
- **Evaluator — Morning Brief:** at the end of each autonomous session, append **one** new section at the **end** of the incident log (or directly after pipeline notes for that day) using the template under **Morning Brief template** below.
- **Nightly — off-allowlist command log:** when using a command not on the Nightly allowlist in `Documentation/AGENTS.md` but allowed by the non-blocking policy (e.g. essential `git`), add a short dated line or subsection: command, reason, and outcome.

## Morning Brief template

Append a section with this **exact** title pattern (level-1 heading, date in `YYYY-MM-DD`):

```markdown
# Morning Brief YYYY-MM-DD

- **Tasks Completed:** (e.g. A2 Grammar database initialized.)
- **Tests Passed:** (e.g. 12/12 unit tests passed.)
- **Failed/Blocked:** (e.g. AI Voice Dialogue blocked due to missing API Key; or `(none)`.)
- **Lint Status:** (List any persistent symmetry warnings; or `(none)`.)
- **Merge (human, after approval):** `git checkout main && git merge nightly/YYYY-MM-DD` (optional: `git checkout main && git pull origin main && git merge nightly/YYYY-MM-DD`)
```

Replace `YYYY-MM-DD` in the title and in the merge line with the session date; replace `nightly/YYYY-MM-DD` with the **actual** branch name if it differs.

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

### [2026-04-07] Flashcard answer checks vs umlauts and ß

- **Feature/Area:** `FlashcardView` typed-answer validation, `GermanFlashcardAnswerNormalization`.
- **Symptom/Error:** Learners typing ASCII substitutes (e.g. `Kase` for `Käse`) or `strasse` for `Straße` could be marked wrong when compared with naive lowercasing.
- **Root Cause:** String comparison did not use German-aware folding or eszett normalization.
- **Fix Applied:** Centralize normalization in `GermanFlashcardAnswerNormalization.normalized(_:)`: map **ß** / **ẞ** to `ss`, then `folding(options: .diacriticInsensitive, locale: de_DE)`, then lowercased; `FlashcardView` compares normalized input to normalized expected.
- **Prevention Rule(s):**
  - Never compare German learner input with raw `lowercased()` only; use shared `GermanFlashcardAnswerNormalization` (or equivalent) for flashcards and any future typed German checks.
  - When adding new corpus fields that users type, add a regression test that covers ä/ö/ü and ß.
- **Validation Evidence:** `FlashcardRegressionTests.testGermanAnswerNormalizationTreatsUmlautsAsEquivalent`, `testGermanAnswerNormalizationMapsEszettForComparison`; lobby A1 filter test `testLobbyA1SelectionFiltersToInitialDataA1CorpusOnly`.

### [PIPELINE-20260408-142417] Automated Pipeline Run

- [2026-04-08 14:24:16 +0200] Pipeline failed: 0 tests, unknown lint violations.

### [PIPELINE-20260408-142702] Automated Pipeline Run

- [2026-04-08 14:27:02 +0200] Pipeline failed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-143100] Automated Pipeline Run

- [2026-04-08 14:31:00 +0200] Pipeline failed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-143538] Automated Pipeline Run

- [2026-04-08 14:35:38 +0200] Pipeline failed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-143858] Automated Pipeline Run

- [2026-04-08 14:38:58 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-144233] Automated Pipeline Run

- [2026-04-08 14:42:33 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-151858] Automated Pipeline Run

- [2026-04-08 15:18:58 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-152805] Automated Pipeline Run

- [2026-04-08 15:28:05 +0200] Pipeline failed: 0 tests, 0 lint violations.

### [PIPELINE-20260408-153113] Automated Pipeline Run

- [2026-04-08 15:31:13 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-153529] Automated Pipeline Run

- [2026-04-08 15:35:29 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-154043] Automated Pipeline Run

- [2026-04-08 15:40:43 +0200] Pipeline passed: 20 tests, 0 lint violations.

### [PIPELINE-20260408-154543] Automated Pipeline Run

- [2026-04-08 15:45:43 +0200] Pipeline failed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-155100] Automated Pipeline Run

- [2026-04-08 15:50:59 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-155921] Automated Pipeline Run

- [2026-04-08 15:59:21 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-160629] Automated Pipeline Run

- [2026-04-08 16:06:29 +0200] Pipeline passed: 21 tests, 0 lint violations.
### [PIPELINE-20260408-165722] Automated Pipeline Run

- [2026-04-08 16:57:22 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-171524] Automated Pipeline Run

- [2026-04-08 17:15:24 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-173014] Automated Pipeline Run

- [2026-04-08 17:30:14 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-174555] Automated Pipeline Run

- [2026-04-08 17:45:55 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-201234] Automated Pipeline Run

- [2026-04-08 20:12:33 +0200] Pipeline passed: 21 tests, 0 lint violations.

### [PIPELINE-20260408-204858] Automated Pipeline Run

- [2026-04-08 20:48:58 +0200] Pipeline passed: 4 tests, 0 lint violations.

### [PIPELINE-20260408-204908] Automated Pipeline Run

- [2026-04-08 20:49:08 +0200] Pipeline failed: 0 tests, 0 lint violations.

### [PIPELINE-20260408-205407] Automated Pipeline Run

- [2026-04-08 20:54:06 +0200] Pipeline failed: 0 tests, 0 lint violations.

### [PIPELINE-20260408-214541] Automated Pipeline Run

- [2026-04-08 21:45:41 +0200] Pipeline failed: 0 tests, 3 lint violations.

### [PIPELINE-20260408-214628] Automated Pipeline Run

- [2026-04-08 21:46:28 +0200] Pipeline failed: 0 tests, 0 lint violations.

### [PIPELINE-20260408-214905] Automated Pipeline Run

- [2026-04-08 21:49:05 +0200] Pipeline failed: 0 tests, 0 lint violations.

### [PIPELINE-20260408-215529] Automated Pipeline Run

- [2026-04-08 21:55:29 +0200] Pipeline failed: 0 tests, 0 lint violations.

---

# Morning Brief 2026-04-09

- **A2 vocabulary:** **103** new A2 lemmas added to `full_vocabulary.json` (repo + nested app copy kept identical). Verbs include infinitive + Partizip II in `englishTranslation`; nouns capitalized with `article`; adjectives lowercased. `swift Scripts/audit_data.swift` clean; `VocabularyDataIntegrityTests` / seeding paths unchanged in intent.
- **GrammarQuizView (Tenses):** **Functional** — A1-gated present-tense cloze from `A1GrammarSentenceLibrary`, MendlsPink prompt / SocietyBlue field, next-question flow; Hallway routes `case .tenses` to `GrammarQuizView`. Unit tests: `GrammarQuizTests`.
- **SwiftLint:** No outstanding rule violations requiring manual design decisions for this batch (test targets retain relaxed `force_unwrapping` as policy).
- **Pipeline:** `Scripts/pipeline.sh` uses `TEST_TIMEOUT_SECONDS=600` so full `xcodebuild test` can finish on slower hosts; prior 300s run timed out before completion.

### [PIPELINE-20260408-221101] Automated Pipeline Run

- [2026-04-08 22:11:01 +0200] Pipeline passed: 23 tests, 0 lint violations.

### [PIPELINE-20260408-222015] Automated Pipeline Run

- [2026-04-08 22:20:14 +0200] Pipeline passed: 23 tests, 0 lint violations.

### Audio Concierge (Flashcards) — 2026-04-09

- **`AudioService`:** `AVSpeechSynthesizer`, voice `de-DE` via optional `AVSpeechSynthesisVoice(language:)` + fallback from `speechVoices()` (no force unwrap). Session: `.playback` + `.spokenAudio` + `.mixWithOthers`. Rate ~0.92× default, pitch 1.06. Manual replay uses `speakGermanReplayCoalesced` (0.15s) after `stopSpeaking(at: .immediate)`.
- **`FlashcardView`:** Auto-speaks German study form (`expectedAnswer`) after each `nextCard()`; centered `speaker.wave.2.bubble.left` in LobbyBoyPurple.
- **Evaluator:** `LearnHappyGermanTests/AudioServiceTests` green via `xcodebuild test -only-testing:LearnHappyGermanTests/AudioServiceTests`. Local `./check_integrity.sh` requires `swiftlint` on `PATH` (not present in this environment).

### Nightly A2 expansion + bakery dialogue — 2026-04-09

- **`VocabularyWord`:** Added optional `pluralSuffix` and `exampleSentence`; `VocabularySeedRecord` + `DataSeeder.importFullVocabularyFromBundle` upsert extended; `Scripts/audit_data.swift` enforces A2 example + plural for der/die/das rows.
- **`full_vocabulary.json`:** **500** unique A2 lemmas (compound-heavy generator in `Scripts/build_a2_500.py`); total vocabulary rows **966** (466 A1 + 500 A2). Re-run script after manual edits to keep A2 count at 500.
- **B1 leak guard:** `BundledData.json` B1 sample word replaced **`lernen` → `Voraussetzung`** (abstract noun); `Scripts/audit_level_overlap.py` passes (no B1 lemmas in `full_vocabulary.json` today).
- **A1 bakery:** `SimpleLifeBakeryDialogueView` + `BakeryScenarioEngine` — multi-turn order / special / price / goodbye; Hallway **AI Dialogue** route.
- **Tests:** `BakeryScenarioTests`, `VocabularyA2FetchPerformanceTests` (synthetic 500-row fetch measure).

### [PIPELINE-20260408-230648] Automated Pipeline Run

- [2026-04-08 23:06:48 +0200] Pipeline failed: 21 tests, 0 lint violations.

### [PIPELINE-20260418-203829] Automated Pipeline Run

- [2026-04-18 20:38:28 +0200] Pipeline passed: 27 tests, 0 lint violations.

### Repository layout reorg — 2026-04-18

- **Change:** `Documentation/` holds `AGENTS.md`, `TODO.md`, `MEMORY.md`, `ProjectMap.md`, and architecture markdown; tooling lives under `Scripts/` (capital **S**); `Data/` placeholder added; unit tests live under `LearnHappyGerman/LearnHappyGermanTests/` (synced); see **Feature-based source layout** below for `Features/` grouping; Xcode explicit test `PBXFileReference` entries removed so `PBXFileSystemSynchronizedRootGroup` is the single source of truth for those files; root `check_integrity.sh` is a thin `exec` wrapper; removed obsolete root `MainLobbyView.swift` / `Theme.swift` stubs.
- **Prevention:** On case-insensitive volumes, avoid maintaining both `scripts/` and `Scripts/` as distinct folders—use one canonical `Scripts/` path and `cd` to repo root inside shell entrypoints.

### [VERIFY-20260418] Post-reorg checks

- `swift Scripts/audit_data.swift`: **Pass** (from repo root).
- `xcodebuild test` (`LearnHappyGerman` scheme, default available iOS simulator): **Pass** (SwiftLint not available in this CI shell; run `./check_integrity.sh` locally for the full gate).

### [PIPELINE-20260418-220705] Automated Pipeline Run

- [2026-04-18 22:07:05 +0200] Pipeline failed: 0 tests, unknown lint violations.

### [PIPELINE-20260418-220927] Automated Pipeline Run

- [2026-04-18 22:09:27 +0200] Pipeline passed: 29 tests, 0 lint violations.

### [PIPELINE-20260418-221821] Automated Pipeline Run

- [2026-04-18 22:18:21 +0200] Pipeline passed: 4 tests, 0 lint violations.

### [PIPELINE-20260418-221918] Automated Pipeline Run

- [2026-04-18 22:19:18 +0200] Pipeline passed: 4 tests, 0 lint violations.

### Feature-based source layout — 2026-04-18

- **Change:** Swift sources under `LearnHappyGerman/LearnHappyGerman/` are grouped into `Features/{Lobby,Flashcards,Hangman,Grammar,Bakery,Vocabulary}/` and `Services/`; tests mirror this under `LearnHappyGermanTests/Features/…`. Xcode app/unit/UI test targets now rely on **empty explicit Compile Sources** lists for those files; `PBXFileSystemSynchronizedRootGroup` compiles the trees (avoids duplicate symbols).
- **Verification:** `xcodebuild test` (`LearnHappyGerman` scheme) passed after the move.

### [PIPELINE-20260418-225143] Automated Pipeline Run

- [2026-04-18 22:51:43 +0200] Pipeline passed: 29 tests, 0 lint violations.

### [PIPELINE-20260418-225458] Automated Pipeline Run

- [2026-04-18 22:54:58 +0200] Pipeline passed: 4 tests, 0 lint violations.

### Single bundled corpus — 2026-04-20

- **Change:** App vocabulary and grammar JSON live under **`Data/`** (`german_vocabulary.json`, `grammar_rules.json`); the Xcode target references **`../Data/*.json`** in Copy Bundle Resources (no duplicate JSON under `LearnHappyGerman/LearnHappyGerman/`). Removed **`BundledData.json`**, **`full_vocabulary.json`**, **`initial_data.json`**. `LocalSeeder.mergeGermanVocabularyFromBundle()` maps extractor fields to `VocabularyWord`. `Scripts/audit_data.swift` reads **`Data/german_vocabulary.json`**.
- **Verification:** `xcodebuild test` (LearnHappyGerman scheme, iPhone 16 simulator) passed; `swift Scripts/audit_data.swift` OK on bundled JSON.

### PDF vocabulary extractor — 2026-04-08

- **Tool:** `python3 Data/scripts/extract_vocab.py` (deps: `Data/scripts/requirements-pdf-extract.txt`, **`pypdf`**). PDFs under repo or parent `reference/vocabulary/`; output `Data/german_vocabulary.json`.
- **Verification run (no PDFs present):** Pass — script exits 0, writes `[]`, integrity report printed, duplicate-headword assertion skipped on empty list.
- **Empty output cause:** `extract_vocab.py` uses **`pypdf`** and looks under **`LearningHappyGerman/reference/vocabulary/`** and **`04_LearningGerman/reference/vocabulary/`** (parent). If no PDFs are found, that directory contained no matching `*.pdf` (wrong folder, wrong filename, or PDFs not synced into this clone). The script prints **resolved repo root**, **PDF dirs**, and **directory listings** to compare with Finder.

### [PIPELINE-20260420-003038] Automated Pipeline Run

- [2026-04-20 00:30:38 +0200] Pipeline passed: 29 tests, 0 lint violations.

### [PIPELINE-20260421-003034] Automated Pipeline Run

- [2026-04-21 00:30:34 +0200] Pipeline failed: 0 tests, 8 lint violations.

### [PIPELINE-20260421-004029] Automated Pipeline Run

- [2026-04-21 00:40:29 +0200] Pipeline passed: 30 tests, 0 lint violations.

### [PIPELINE-20260421-004618] Automated Pipeline Run

- [2026-04-21 00:46:18 +0200] Pipeline passed: 30 tests, 0 lint violations.
