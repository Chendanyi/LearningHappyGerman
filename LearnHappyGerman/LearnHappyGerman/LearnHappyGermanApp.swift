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
        let schema = Schema([
            Item.self,
            VocabularyWord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
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
}
