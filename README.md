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
| `Data/` | **`german_vocabulary.json`**, **`grammar_rules.json`**, and `Data/scripts/` (extractor); canonical copy for the app (Xcode bundles these files) |

Deeper file-by-file notes live in **`Documentation/ProjectMap.md`**.

## If something goes wrong

- **App won’t start or data looks broken after an update** — delete the app from the simulator or device and install again so storage can be recreated (common during active development).
- **Black or frozen simulator screen** — make sure you are running the **LearnHappyGerman** app scheme (not a test target). Try **Simulator → Device → Erase All Content and Settings**, then run again.

## Contributing & vocabulary tooling

Maintainers use **`./check_integrity.sh`** (lint, **`Scripts/audit_data.swift`** on `german_vocabulary.json`, and tests) before merging.

**Goethe PDF word lists:** put licensed PDFs under **`reference/vocabulary/`** (and/or the parent `04_LearningGerman/reference/vocabulary/`). Install Python deps with **`python3 -m pip install -r Data/scripts/requirements-pdf-extract.txt`** (use a **venv** if your system pip is protected). Run **`python3 Data/scripts/extract_vocab.py`** to refresh **`Data/german_vocabulary.json`**. To add English glosses with **googletrans** (unofficial Google Translate client; requires network; quality varies), run **`python3 Data/scripts/extract_vocab.py --translate`** after extract, or **`python3 Data/scripts/extract_vocab.py --translate-only`** to update an existing JSON. Re-running the PDF step **preserves** existing non-empty `englishTranslation` values unless you pass **`--no-preserve`**. Machine translations can be wrong—spot-check critical glosses. On each launch, the app **inserts** missing `(word, level)` rows and **backfills** `englishTranslation` on existing rows when the store value is empty but the bundle JSON provides a gloss (so you usually only need a **rebuild + run** after updating `Data/german_vocabulary.json`). For other field changes, or if you need a clean slate, delete the app or reset storage. Grammar seeds live in **`Data/grammar_rules.json`**. Legacy **`scripts/vocab_processor.py`** targets the old `{ "version", "words" }` shape and is optional.

---

*Last updated: 2026-04-08 (LocalSeeder backfills empty English from bundled JSON on relaunch)*
