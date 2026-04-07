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
                .task {
                    guard !hasSeeded else { return }
                    hasSeeded = true
                    seedVocabularyIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedVocabularyIfNeeded() {
        let context = ModelContext(sharedModelContainer)
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
