# Learning Happy German

An iOS app for learning German with a simple **lobby → hallway → rooms** flow. You pick your level (A1–C2), then open activities such as flashcards, hangman, grammar practice, and a short dialogue scene.

## What you can do in the app

- **Choose your level** on the main screen (A1 through C2), styled like a hotel concierge board.
- **Flashcards** — study words for your level, hear German pronunciation, and mark progress as you go.
- **Hangman** — guess letters for words at your level; nouns show the correct article (der / die / das) when relevant.
- **Tenses** — fill-in exercises for beginner grammar (A1 present tense).
- **AI Dialogue** — a short, guided bakery-style conversation for A1 practice.

On first launch, the app loads bundled vocabulary and grammar from its own data files. Everything stays on your device unless you later use features that sync data (if enabled in a future build).

## Running the app (developers)

1. Open **`LearnHappyGerman/LearnHappyGerman.xcodeproj`** in Xcode.
2. Select the **`LearnHappyGerman`** scheme and an **iPhone simulator** (or a connected device).
3. Press **Run** (▶).

You need a recent Xcode with the iOS SDK that matches the project’s deployment target.

## Repository layout (short)

| Folder | Purpose |
|--------|--------|
| `LearnHappyGerman/` | Xcode project, app source, and bundled JSON vocabulary |
| `Documentation/` | Roadmap, architecture notes, and project memory for contributors |
| `Scripts/` | Quality checks and helper scripts (for example vocabulary audits) |

Deeper file-by-file notes live in **`Documentation/ProjectMap.md`**.

## If something goes wrong

- **App won’t start or data looks broken after an update** — delete the app from the simulator or device and install again so storage can be recreated (common during active development).
- **Black or frozen simulator screen** — make sure you are running the **LearnHappyGerman** app scheme (not a test target). Try **Simulator → Device → Erase All Content and Settings**, then run again.

## Contributing & vocabulary tooling

Maintainers use **`./check_integrity.sh`** (lint, data checks, and tests) before merging. To convert external word lists into the app’s JSON format, see **`Scripts/vocab_processor.py`** and the notes in **`Documentation/`**.

---

*Last updated: 2026-04-18*
