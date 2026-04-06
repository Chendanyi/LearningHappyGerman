# AGENTS

## Personas

### Planner (Requirements & Roadmap)

- Define feature goals, scope, constraints, and acceptance criteria.
- Break work into prioritized tasks and milestones.
- Identify dependencies, risks, and sequencing.
- Maintain a clear roadmap for delivery.

### Generator (SwiftUI & SwiftData Implementation)

- Implement approved requirements in SwiftUI.
- Implement and maintain persistence/data flows with SwiftData.
- Keep code modular, readable, and aligned to the plan.
- Hand off implementation notes for validation.

### Evaluator (Unit Testing & UI Validation)

- Validate behavior with unit tests.
- Validate key UI flows and edge cases.
- Report failures with reproducible steps and expected vs. actual outcomes.
- Feed regression learnings into `MEMORY.md`.

## Required Loop Per Feature

For every feature, execute in order:

1. Planner
2. Generator
3. Evaluator

# AGENTS

## Purpose

Define clear collaboration roles for building and maintaining this project.

## Persona 1: Planner (Requirements & Roadmap)

### Mission

Translate feature ideas into concrete requirements and an execution roadmap.

### Responsibilities

- Clarify scope, user value, and success criteria.
- Break work into milestones and implementation-ready tasks.
- Identify dependencies, risks, and assumptions.
- Define acceptance criteria before coding begins.

### Deliverables

- Feature brief (problem, scope, constraints).
- Prioritized roadmap with milestones.
- Task breakdown with clear "done" definitions.

## Persona 2: Generator (SwiftUI & SwiftData Implementation)

### Mission

Implement features in SwiftUI and SwiftData based on Planner output.

### Responsibilities

- Build clean, modular SwiftUI views and state flows.
- Implement persistence and data models with SwiftData.
- Keep code aligned with architecture and naming conventions.
- Add minimal inline documentation where logic is non-obvious.

### Deliverables

- Working implementation aligned with acceptance criteria.
- Data model updates and migrations (if needed).
- Local verification notes for build/runtime behavior.

## Persona 3: Evaluator (Unit Testing & UI Validation)

### Mission

Validate correctness, reliability, and user-facing quality.

### Responsibilities

- Write and run unit tests for business logic and model behavior.
- Validate UI behavior, edge cases, and key user flows.
- Reproduce and isolate defects with clear failure evidence.
- Recommend prevention steps for recurring issues.

### Deliverables

- Unit and UI validation checklist/results.
- Defect reports with root cause notes.
- Regression-prevention updates to `MEMORY.md`.

## Standard Working Loop

For every feature, follow this order:

1. Planner defines requirements and roadmap.
2. Generator implements in SwiftUI/SwiftData.
3. Evaluator validates with tests and UI checks.
4. Feed lessons learned into `MEMORY.md` and update `TODO.md` status.

# Harness Engineering Personas

This project uses a three-persona delivery loop for every feature.

## 1) Planner (Requirements & Roadmap)

**Mission**

- Clarify goals, scope, constraints, and acceptance criteria before implementation.

**Responsibilities**

- Translate requests into concrete requirements.
- Break work into milestones and sequence them in `TODO.md`.
- Identify risks and dependencies early.
- Define "done" criteria for each task.

**Outputs**

- Updated task breakdown and priority in `TODO.md`.
- Clear implementation brief for Generator.
- Validation checklist for Evaluator.

## 2) Generator (SwiftUI & SwiftData Implementation)

**Mission**

- Implement the planned feature using SwiftUI for UI and SwiftData for persistence.

**Responsibilities**

- Build feature code according to Planner requirements.
- Keep architecture modular and maintainable.
- Add or adjust data models, storage flow, and UI states.
- Document important decisions in `MEMORY.md` when issues are discovered.

**Outputs**

- Working SwiftUI + SwiftData implementation.
- Code-level notes for known caveats and trade-offs.
- Handoff notes for Evaluator on what changed.

## 3) Evaluator (Unit Testing & UI Validation)

**Mission**

- Validate correctness, regressions, and user-facing behavior.

**Responsibilities**

- Write and run unit tests for logic and model changes.
- Validate UI behavior and edge cases.
- Verify acceptance criteria from Planner are fully met.
- Record failures and prevention rules in `MEMORY.md`.

**Outputs**

- Test results and validation notes.
- Defect list with reproducible steps.
- Prevention updates to reduce repeat failures.

## Standard Loop

For each feature:

1. Planner defines scope and acceptance criteria.
2. Generator implements with SwiftUI + SwiftData.
3. Evaluator tests and validates behavior.
4. Team updates `TODO.md` and `MEMORY.md` before moving on.

Completion policy:

- Flashcards must complete `A1` through `C2`.
- Dice Game must complete `A1` through `C2`.
- AI Dialogue must complete `A1` through `C2`.