# Bundle assets

Canonical JSON lives under the repo’s **`Data/`** folder (`german_vocabulary.json`, `grammar_rules.json`). The **LearnHappyGerman** target references `../Data/*.json` in Xcode and copies them into the app at build time—do not duplicate copies under `LearnHappyGerman/LearnHappyGerman/`.
