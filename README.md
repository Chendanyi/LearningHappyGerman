# Learning Happy German

An iOS app for learning German with a simple **lobby → hallway → rooms** flow. You pick your level (A1–C2), then open activities such as flashcards, hangman, grammar practice, and a short dialogue scene.

## What you can do in the app

- **Choose your level** on the main screen (A1 through C2), styled like a hotel concierge board.
- **Flashcards** — study words for your level, hear German pronunciation, and mark progress as you go. The card front shows the English gloss when the vocabulary row has one; otherwise it shows a short “listen and type the German answer” hint (example sentences stay off the front so they don’t give away the target word or the wrong sense).
- **Hangman** — guess letters for words at your level; nouns show the correct article (der / die / das) when relevant.
- **Tenses** — fill-in exercises for beginner grammar (A1 present tense).
- **AI Dialogue** — a short, guided bakery-style conversation for A1 practice.

On first launch, the app merges **`german_vocabulary.json`** (Goethe-style list from `Data/scripts/extract_vocab.py`) into SwiftData and loads **`grammar_rules.json`** for the grammar room. Everything stays on your device unless you later use features that sync data (if enabled in a future build).

## Running the app (developers)

1. Open **`LearnHappyGerman/LearnHappyGerman.xcodeproj`** in Xcode.
2. Select the **`LearnHappyGerman`** scheme and an **iPhone simulator** (or a connected device).
3. Press **Run** (▶).

You need a recent Xcode with the iOS SDK that matches the project’s deployment target.

## Repository layout (short)

| Folder | Purpose |
|--------|--------|
| `LearnHappyGerman/` | Xcode project and Swift sources; JSON assets are referenced from **`Data/`** and copied into the app at build time |
| `Documentation/` | Roadmap, architecture notes, and project memory for contributors |
| `Scripts/` | Quality checks and helper scripts (for example vocabulary audits) |
| `reference/vocabulary/` | Optional Goethe PDF sources for `Data/scripts/extract_vocab.py` |
| `Data/` | **`german_vocabulary.json`**, **`grammar_rules.json`**, **`Data/README.md`** (bundle schema + rule index), and `Data/scripts/` (extractor); canonical copy for the app (Xcode bundles the JSON only) |

Deeper file-by-file notes live in **`Documentation/ProjectMap.md`**.

## If something goes wrong

- **App won’t start or data looks broken after an update** — delete the app from the simulator or device and install again so storage can be recreated (common during active development).
- **Black or frozen simulator screen** — make sure you are running the **LearnHappyGerman** app scheme (not a test target). Try **Simulator → Device → Erase All Content and Settings**, then run again.

## Contributing & vocabulary tooling

Maintainers use **`./check_integrity.sh`** (lint, **`Scripts/audit_data.swift`** on `german_vocabulary.json`, and tests) before merging.

**Goethe PDF word lists:** put licensed PDFs under **`reference/vocabulary/`** (and/or the parent `04_LearningGerman/reference/vocabulary/`). Install Python deps with **`python3 -m pip install -r Data/scripts/requirements-pdf-extract.txt`** (use a **venv** if your system pip is protected). Run **`python3 Data/scripts/extract_vocab.py`** to refresh **`Data/german_vocabulary.json`**. To add English glosses with **googletrans** (unofficial Google Translate client; requires network; quality varies), run **`python3 Data/scripts/extract_vocab.py --translate`** after extract, or **`python3 Data/scripts/extract_vocab.py --translate-only`** to update an existing JSON. Re-running the PDF step **preserves** existing non-empty `englishTranslation` values unless you pass **`--no-preserve`**. Machine translations can be wrong—spot-check critical glosses. On each launch, the app **inserts** missing `(word, level)` rows and **backfills** `englishTranslation` on existing rows when the store value is empty but the bundle JSON provides a gloss (so you usually only need a **rebuild + run** after updating `Data/german_vocabulary.json`). For other field changes, or if you need a clean slate, delete the app or reset storage. **Grammar:** **`Data/grammar_rules.json`** (**version 3**) bundles **19 A1 rules** with structured fields: `module`, `title`, `german_title`, `formula`, English `description`, `description_cn`, and `examples` as `{ "de", "en" }` objects. See **`Data/README.md`**. SwiftData store file is **`learnhappygerman-v10.store`** (schema includes `GrammarRule` example pairs). Editing titles adds **new** rows on first launch; changing body text for an existing `title` does not refresh old rows—reinstall or reset storage.

**Migration note (2026-04):** legacy scripts that wrote `LearnHappyGerman/**/full_vocabulary.json` were removed (`scripts/build_a2_500.py`, `scripts/audit_level_overlap.py`, `scripts/merge_a2_vocab_batch.py`, `scripts/vocab_processor.py`). Use the `Data/scripts/extract_vocab.py` pipeline as the single source for bundled vocabulary.

**JSON cleanup:** **`python3 Data/scripts/cleanup_german_vocabulary.py`** fixes common extractor noise (noun lemma casing, plural field leaking example sentences into `examples`, blank optional fields) and **strips CJK characters** from string fields. It does not translate Chinese to English—if a gloss was Chinese-only, re-run **`extract_vocab.py --translate-only`** after cleanup. Use **`--in-place`** to overwrite `Data/german_vocabulary.json`, or **`-o`** for a new file.

---

*Last updated: 2026-04-26 (`grammar_rules.json` v3 + `learnhappygerman-v10.store`)*
