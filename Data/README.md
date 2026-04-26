# Data bundle (canonical JSON)

This folder is the **single source of truth** for vocabulary and grammar JSON. The Xcode target copies these files into the app bundle (`Copy Bundle Resources` → `../Data/*.json`).

| File | Role |
|------|------|
| `german_vocabulary.json` | Goethe-style vocabulary corpus (array of word records). |
| `grammar_rules.json` | A1 grammar reference rules for bundled ingestion into SwiftData. |
| `scripts/` | Python tooling (`extract_vocab.py`, `cleanup_german_vocabulary.py`, `requirements-pdf-extract.txt`). |

---

## `grammar_rules.json`

**Top-level shape (v3)**

```json
{
  "version": 3,
  "rules": [ /* ... */ ]
}
```

- **`version`** — Integer; **3** is the current structured schema. Bump when you change shape or do a major editorial edition.
- **`rules`** — Array of objects. Imported by `LocalSeeder.importGrammarRulesFromBundle()`.

**Each rule object** (fields must match the app decoder):

| Field | Type | Notes |
|--------|------|--------|
| `module` | string (optional) | Group label, e.g. `Sentence Structure`, `Verbs`, `Imperative`. |
| `title` | string | **Unique** English title (merge key). Changing other fields but keeping the same `title` does not update SwiftData until reinstall/reset. |
| `level` | string | CEFR code, e.g. `"A1"`. |
| `german_title` | string | German grammar term (e.g. `Verbzweitstellung`). |
| `formula` | string | Structural pattern. |
| `description` | string | Concise **English** explanation (stored in `GrammarRule.explanation`). |
| `description_cn` | string | **Simplified Chinese** explanation (stored in `GrammarRule.descriptionCN`). |
| `examples` | array | Non-empty. Each item: `{ "de": "…", "en": "…" }`. |

**SwiftData (`GrammarRule`)** maps: `module`, `title`, `germanTitle`, `formula`, `explanation` ← `description`, `descriptionCN` ← `description_cn`, `exampleGermanLines` / `exampleEnglishLines` ← `examples`.

**Current A1 rules (19)**

| Module | Titles |
|--------|--------|
| Sentence Structure | Verb Second (V2); Yes–No Questions; W-Questions; Conjunctions (und, oder, aber) |
| Imperative | Imperative |
| Verbs | Present Tense — Regular Verbs; Present Tense — Irregular Verbs; Modal Verbs; Separable Verbs |
| Nouns & Articles | Gender (der, die, das); Definite and Indefinite Articles; Plural Forms; Negation (kein and nicht) |
| Cases | Nominative Case; Accusative Case |
| Pronouns | Personal Pronouns; Possessive Determiners |
| Prepositions | Time Prepositions (am, um, im); Place Prepositions (aus, in, nach) |

**Verify:** `python3 -m json.tool Data/grammar_rules.json`

---

## `german_vocabulary.json`

**Top-level shape:** JSON **array** of word objects (not `{ "version", "words" }`).

**Common fields** (subset; optional keys may be omitted or `null`):

| Field | Type | Notes |
|--------|------|--------|
| `word` | string | Lemma (nouns capitalized). |
| `type` | string | e.g. `"noun"`, `"other"` (maps to app category). |
| `level` | string | `"A1"`, `"A2"`, … |
| `article` | string or null | For nouns: `der` / `die` / `das`. |
| `plural` | string or null | Plural suffix or form only (no leaked example text after cleanup). |
| `examples` | array of strings | Example sentences. |
| `englishTranslation` | string or null | Optional gloss; may be filled via `Data/scripts/extract_vocab.py --translate`. |
| `auxiliary`, `perfect` | string or null | Verb perfect-tense helpers from PDF extract. |
| `conjugation` | string or null | If present in source. |

**Tooling:** `python3 Data/scripts/extract_vocab.py` (PDF → JSON), `python3 Data/scripts/cleanup_german_vocabulary.py` (structural + CJK cleanup). **`Scripts/audit_data.swift`** validates `german_vocabulary.json` in CI.

---

*Last updated: 2026-04-26 (`grammar_rules.json` v3 schema)*
