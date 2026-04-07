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
    @State private var selectedLevel: CEFRLevel?

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
            MainLobbyView(selectedLevel: $selectedLevel)
        }
        .modelContainer(sharedModelContainer)
    }
}
