# Hybrid SwiftData Architecture (Planner)

The app uses a single SwiftData store with two complementary model families:

## Vocabulary (`VocabularyWord`)

- **Purpose:** Lexical entries for learning (German headword, optional article, English gloss, CEFR level as `String`, category as `String`, mastery flag, `version`).
- **Identity:** `id: UUID` with `@Attribute(.unique)`; merge/sync keys use `(germanWord, level)` as strings.
- **Versioning:** `version: Int` starts at `1` and should be incremented when editorial or import logic changes the pedagogical content of a row (enables future migrations and sync conflict rules).
- **Query performance:** `#Index<VocabularyWord>([\.germanWord], [\.level])` indexes the two string fields used for filtering and search. UI still uses `CEFRLevel` enum for routing; persisted `level` matches `CEFRLevel.rawValue` (e.g. `"A1"`).

## Grammar (`GrammarRule`)

- **Purpose:** Bundled A1 reference rules from `grammar_rules.json` **v3**: `module`, `title`, `germanTitle`, `formula`, English `explanation`, `descriptionCN`, `level`, and paired `exampleGermanLines` / `exampleEnglishLines` (from JSON `examples` with `de` / `en`).
- **Scope:** `level` is a CEFR label (`A1`…`C2`); no relationship to `VocabularyWord` in the current schema (add links later if needed).

## Remote sync placeholder (`SyncService`)

- **Contract:** `RemoteVocabularyPayload` / `RemoteWordDTO` (no `isMastered` in JSON — server must not own user progress).
- **Merge key:** `germanWord` + `level` as `String` (see `SyncService.stableKey`). Updates refresh article, gloss, category, and `version`; **never** overwrites `isMastered` on existing rows.
- **Fetch:** `fetchRemotePayload(from:)` uses `URLSession` (wire authentication and ETags later).

## Bundled ingestion (`LocalSeeder`)

- **Source:** `Data/german_vocabulary.json` and `Data/grammar_rules.json` (grammar payload `version` **3**) in the repo; Xcode copies them into the app bundle at build time.
- **When:** Every launch runs an **idempotent merge** of vocabulary rows missing from SwiftData and backfills empty in-store `englishTranslation` when the bundle now provides one; grammar rules merge by unique `title`. `UserDefaults` key `hasImportedBundledData.v1` gates one-time ingestion audit logging only.
- **Observability:** Successful first run appends markdown to Application Support `LearnHappyGerman/MEMORY_ingestion_appendix.md`. Failed or corrupt JSON surfaces a **Human Takeover** alert.

## Design notes

- Grammar rules persist paired German/English example lines (`exampleGermanLines` / `exampleEnglishLines` from JSON `examples` with `de` / `en`). Extend the model if you need per-example audio, links, or richer filtering.

