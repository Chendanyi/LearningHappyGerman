# 🥨 Learning Happy German

> **A curated, AI-driven iOS experience for mastering German scenarios.**

[![Platform: iOS 18.2+](https://img.shields.io/badge/platform-iOS%2018.2%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift: 5](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org)
[![Aesthetic: Grand Budapest](https://img.shields.io/badge/Aesthetic-Grand%20Budapest-FFC0CB.svg)](#)

---

## 🏛 Project Vision

**Learning Happy German** follows a **lobby → hallway → rooms** design philosophy: give beginner and intermediate learners an immersive, cinematic environment that feels like moving through a grand hotel—each room is an activity, not a sterile menu.

### ✨ Key Features

| Feature | Description | Status |
| :--- | :--- | :--- |
| **📍 CityWalk Map** | Interactive 2D map with **12** real-life scenarios (bakery, train station, hotel, and more). | ✅ Live |
| **🤖 Scenario Dialogues** | Multi-turn roleplay via **`CityScenarioEngine`**, **`ScenarioCatalog`**, and **`ScenarioPromptProvider`** (12 hotspot-specific AI personas + German TTS after each clerk line). | ✅ Live |
| **🗂️ Smart Flashcards** | Audio-first vocabulary with English glosses and SwiftData persistence. | ✅ Live |
| **🕹️ Classroom Games** | Hangman and grammar tense quizzes for **A1**. | ✅ Live |
| **🎧 Audio Service** | **`AVSpeechSynthesizer`** for German pronunciation. | ✅ Live |

---

## 🚀 Running the App

1. **Environment**: **Xcode 15+** with an **iOS SDK** matching the project deployment target (**iOS 18.2** in the current Xcode project).
2. **Open**: `LearnHappyGerman/LearnHappyGerman.xcodeproj`.
3. **Target**: Select the **`LearnHappyGerman`** scheme and a simulator (or device).
4. **Execute**: Press **⌘ R**.

**API keys (local only):** Copy **`LearnHappyGerman/Secrets.xcconfig.example`** to **`LearnHappyGerman/Secrets.xcconfig`** (gitignored) and set **`GOOGLE_AI_API_KEY`**. **`AppInfoAdditions.plist`** merges that build setting into the app Info.plist (via **`INFOPLIST_FILE`** + **`GENERATE_INFOPLIST_FILE`**); **`AppSecrets.xcconfig`** `#include?` **`Secrets.xcconfig`**. **`GoogleGenerativeAIConfiguration`** reads **`GOOGLE_AI_API_KEY`** from **`Bundle.main`** and sets the default **`GenerativeModel`** name (currently **`gemini-2.5-flash`**, the model your Google AI key must support for `generateContent`); **`GeminiGenerativeModelFactory`** and **`GenerativeAIService`** use that name. SPM: **`https://github.com/google/generative-ai-swift`** (`GoogleGenerativeAI`).

> **Note**: If data looks broken after an update, reset simulator storage (**Simulator → Erase All Content and Settings**) or delete and reinstall the app.

---

## 🛠 Repository Architecture

The repo separates bundled data, quality scripts, and UI:

- **`LearnHappyGerman/`** — Xcode project, SwiftUI sources, and assets.
- **`Data/`** — Source of truth: **`german_vocabulary.json`**, **`grammar_rules.json`**, and **`Data/scripts/`** (extractors). See **`Data/README.md`** for schema notes.
- **`Scripts/`** — Swift/Python helpers invoked by **`./check_integrity.sh`** (lint, data audit, tests).
- **`Documentation/`** — Architecture notes and [**Project Memory**](./Documentation/MEMORY.md).

More detail: **`Documentation/ProjectMap.md`**.

---

## 📚 Vocabulary & Data Pipeline

Goethe-style word lists feed the bundled JSON the app ships with.

### 1. Extraction & translation

- **Source**: Licensed PDFs in **`../reference/vocabulary/`** (sibling of this repo when checked out under **`04_LearningGerman/`**; see **`Data/scripts/extract_vocab.py`**).
- **Commands**: `python3 Data/scripts/extract_vocab.py` — optional **`--translate`** / **`translate-only`** for English glosses (network; quality varies).
- **Output**: **`Data/german_vocabulary.json`**.

### 2. Integrity & cleanup

Before merging, maintainers run **`./check_integrity.sh`** (SwiftLint, **`Scripts/audit_data.swift`**, unit/UI tests). Optional: **`python3 Data/scripts/cleanup_german_vocabulary.py`** (normalize lemmas, fix plural/example leaks, strip stray CJK in string fields).

---

## 🗺 Roadmap

- [ ] **3D immersive mode**: Explore CityWalk in a RealityKit 3D space.
- [ ] **SRS**: Spaced repetition (e.g. SM-2) for flashcards.
- [ ] **Voice interaction**: Speech-to-text for open-ended dialogue practice.

---

*Last updated: 2026-05-06 (default Gemini model `gemini-2.5-flash`) | Built with ❤️ for German learners.*
