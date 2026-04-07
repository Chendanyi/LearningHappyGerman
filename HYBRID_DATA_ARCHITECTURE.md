# Hybrid SwiftData Architecture (Planner)

The app uses a single SwiftData store with two complementary model families:

## Vocabulary (`VocabularyWord`)

- **Purpose:** Lexical entries for learning (German headword, optional article, English gloss, CEFR level as `String`, category as `String`, mastery flag, `version`).
- **Identity:** `id: UUID` with `@Attribute(.unique)`; merge/sync keys use `(germanWord, level)` as strings.
- **Versioning:** `version: Int` starts at `1` and should be incremented when editorial or import logic changes the pedagogical content of a row (enables future migrations and sync conflict rules).
- **Query performance:** `#Index<VocabularyWord>([\.germanWord], [\.level])` indexes the two string fields used for filtering and search. UI still uses `CEFRLevel` enum for routing; persisted `level` matches `CEFRLevel.rawValue` (e.g. `"A1"`).

## Grammar (`GrammarRule`)

- **Purpose:** Tense explanations and example lines keyed by `title`, `explanation`, `level` (`String`), and `exampleSentences: [String]`.
- **Scope:** `level` is a CEFR label (`A1`…`C2`); no relationship to `VocabularyWord` in the current schema (add links later if needed).

## Remote sync placeholder (`SyncService`)

- **Contract:** `RemoteVocabularyPayload` / `RemoteWordDTO` (no `isMastered` in JSON — server must not own user progress).
- **Merge key:** `germanWord` + `level` as `String` (see `SyncService.stableKey`). Updates refresh article, gloss, category, and `version`; **never** overwrites `isMastered` on existing rows.
- **Fetch:** `fetchRemotePayload(from:)` uses `URLSession` (wire authentication and ETags later).

## Bundled ingestion (`LocalSeeder`)

- **Source:** `BundledData.json` in the app target (copied with the bundle).
- **When:** First launch only, unless `UserDefaults` key `hasImportedBundledData.v1` is already set (or an existing non-empty vocabulary store triggers a legacy skip).
- **Observability:** Successful runs append markdown to Application Support `LearnHappyGerman/MEMORY_ingestion_appendix.md` for copying into this repo’s `MEMORY.md`. Failed or corrupt JSON surfaces a **Human Takeover** alert (no silent fallback from bundled data).

## Design notes

- Grammar rules ship as `exampleSentences` arrays; split into a separate model later if you need per-example filtering or audio links.
