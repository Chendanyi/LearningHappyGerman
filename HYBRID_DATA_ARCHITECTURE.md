# Hybrid SwiftData Architecture (Planner)

The app uses a single SwiftData store with two complementary model families:

## Vocabulary (`VocabularyWord`)

- **Purpose:** Lexical entries for learning (German headword, article, English gloss, CEFR level, category, mastery flag).
- **Versioning:** `version: Int` starts at `1` and should be incremented when editorial or import logic changes the pedagogical content of a row (enables future migrations and sync conflict rules).
- **Query performance:** `#Index` was removed after it contributed to store init failures alongside enum-heavy schemas; reintroduce only on plain `String` fields after profiling. Level filtering remains in-memory in flashcards.

## Grammar (`GrammarRule`)

- **Purpose:** Tense explanations, example lines, and formal rule text (patterns, auxiliaries, word order).
- **Optional scope:** `applicableLevelCode` / `applicableLevel` when a rule is tied to a CEFR band.
- **Relationship:** Optional `relatedWord` on `GrammarRule` uses `@Relationship(inverse: \VocabularyWord.grammarRules)`; `VocabularyWord.grammarRules` uses `@Relationship(deleteRule: .cascade)`.
- **Optional level on rules:** Persist `applicableLevelCode: String?` (not `CEFRLevel?`) to avoid optional-enum persistence issues; use `GrammarRule.applicableLevel` for `CEFRLevel?` access when needed.

## Remote sync placeholder (`SyncService`)

- **Contract:** `RemoteVocabularyPayload` / `RemoteWordDTO` (no `isMastered` in JSON — server must not own user progress).
- **Merge key:** `germanWord` + `CEFRLevel` (see `SyncService.stableKey`). Updates refresh article, gloss, category, and `version`; **never** overwrites `isMastered` on existing rows.
- **Fetch:** `fetchRemotePayload(from:)` uses `URLSession` (wire authentication and ETags later).

## Bundled ingestion (`LocalSeeder`)

- **Source:** `BundledData.json` in the app target (copied with the bundle).
- **When:** First launch only, unless `UserDefaults` key `hasImportedBundledData.v1` is already set (or an existing non-empty vocabulary store triggers a legacy skip).
- **Observability:** Successful runs append markdown to Application Support `LearnHappyGerman/MEMORY_ingestion_appendix.md` for copying into this repo’s `MEMORY.md`. Failed or corrupt JSON surfaces a **Human Takeover** alert (no silent fallback from bundled data).

## Design notes

- Grammar rules that apply globally (no single headword) leave `relatedWord` unset.
- Large example blobs stay as `String` for simplicity; split into a separate model later if you need per-example filtering or audio links.

