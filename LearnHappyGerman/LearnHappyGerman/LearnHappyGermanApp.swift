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
            MainLobbyView()
                .environmentObject(appState)
                // Attach the container to the root view so SwiftData’s environment reaches all screens
                // (Scene-only attachment can contribute to a blank first frame in some setups).
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

    @MainActor
    private func runInitialBootstrap() async {
        let context = ModelContext(sharedModelContainer)
        let importKey = LocalSeeder.importCompletedDefaultsKey

        if UserDefaults.standard.bool(forKey: importKey) {
            seedFallbackIfEmpty(context: context)
            return
        }

        let existingWords = (try? context.fetchCount(FetchDescriptor<VocabularyWord>())) ?? 0
        if existingWords > 0 {
            UserDefaults.standard.set(true, forKey: importKey)
            try? IngestionAuditLogger.appendLegacyStoreLog(existingWordCount: existingWords)
            seedFallbackIfEmpty(context: context)
            return
        }

        let seeder = LocalSeeder(context: context)
        do {
            let result = try seeder.importFromBundle()
            UserDefaults.standard.set(true, forKey: importKey)
            do {
                try IngestionAuditLogger.appendIngestionLog(
                    wordCount: result.wordCount,
                    ruleCount: result.ruleCount,
                    bundleVersion: result.bundleVersion
                )
            } catch {
                print("Ingestion audit log failed (non-fatal): \(error)")
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            appState.humanTakeoverMessage = """
            Bundled data import failed. \(message)

            Fix BundledData.json, reset the app, or reinstall. Developer: copy MEMORY_ingestion_appendix.md from the app container when import succeeds.
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
            Item.self,
            VocabularyWord.self,
            GrammarRule.self
        ])

        let memoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        let folder = appSupport.appendingPathComponent("LearnHappyGerman", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let storeURL = folder.appendingPathComponent("learnhappygerman-v8.store", isDirectory: false)
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
