//
//  LearnHappyGermanApp.swift
//  LearnHappyGerman
//
//  Created by Chen Dan Yi on 2026/4/7.
//

import SwiftUI
import SwiftData

@main
struct LearnHappyGermanApp: App {
    @StateObject private var appState = AppState()
    @State private var hasSeeded = false

    var sharedModelContainer: ModelContainer = {
        makeModelContainer()
    }()

    var body: some Scene {
        WindowGroup {
            rootView
                .environmentObject(appState)
                // Attach the container to the root view so SwiftData's environment reaches all screens.
                .modelContainer(sharedModelContainer)
                .task {
                    guard !hasSeeded else { return }
                    hasSeeded = true
                    // Let the first frame paint before SwiftData import work runs on the main actor.
                    await Task.yield()
                    await runInitialBootstrap()
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        if ProcessInfo.processInfo.arguments.contains("UITEST_HANGMAN_DIRECT") {
            NavigationStack {
                HangmanGameView()
            }
        } else {
            MainLobbyView()
        }
    }

    @MainActor
    private func runInitialBootstrap() async {
        let context = ModelContext(sharedModelContainer)
        let importKey = LocalSeeder.importCompletedDefaultsKey
        appState.isInitializingVocabulary = true
        appState.initializationProgress = 0
        defer {
            appState.initializationProgress = 1
            appState.isInitializingVocabulary = false
        }

        let seeder = LocalSeeder(context: context)
        do {
            let mergeResult = try seeder.mergeGermanVocabularyFromBundle()
            let ruleCount = try seeder.importGrammarRulesFromBundle()
            if !UserDefaults.standard.bool(forKey: importKey) {
                UserDefaults.standard.set(true, forKey: importKey)
                do {
                    try IngestionAuditLogger.appendIngestionLog(
                        wordCount: mergeResult.totalInFile,
                        ruleCount: ruleCount,
                        bundleVersion: 3
                    )
                } catch {
                    print("Ingestion audit log failed (non-fatal): \(error)")
                }
            }
            if mergeResult.inserted > 0 || mergeResult.updated > 0 {
                print(
                    "LearnHappyGerman: merged \(mergeResult.inserted) new rows, "
                        + "updated \(mergeResult.updated) English glosses from german_vocabulary.json "
                        + "(\(mergeResult.totalInFile) in bundle file)"
                )
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            appState.humanTakeoverMessage = """
            Vocabulary import failed. \(message)

            Fix german_vocabulary.json and grammar_rules.json in the app bundle, reset the app, or reinstall.
            """
            return
        }

        seedFallbackIfEmpty(context: context)
    }

    private func seedFallbackIfEmpty(context: ModelContext) {
        let seeder = DataSeeder(context: context)
        do {
            try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)
        } catch {
            print("Vocabulary seed failed: \(error)")
        }
    }

    /// Uses a **versioned** store filename so simulator installs stuck on a broken migration can open a fresh file.
    /// If the on-disk store still fails (schema edge cases), falls back to an in-memory container so the app runs.
    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            VocabularyWord.self,
            GrammarRule.self
        ])

        let memoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Could not resolve Application Support directory.")
        }
        let folder = appSupport.appendingPathComponent("LearnHappyGerman", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let storeURL = folder.appendingPathComponent("learnhappygerman-v11.store", isDirectory: false)
        let diskConfiguration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [diskConfiguration])
        } catch let diskError {
            print(
                "SwiftData persistent ModelContainer failed: \(diskError). "
                    + "Trying in-memory store."
            )
            do {
                return try ModelContainer(for: schema, configurations: [memoryConfiguration])
            } catch let memoryError {
                fatalError(
                    "SwiftData could not create ModelContainer. "
                        + "Persistent error: \(diskError). "
                        + "In-memory error: \(memoryError)"
                )
            }
        }
    }
}
