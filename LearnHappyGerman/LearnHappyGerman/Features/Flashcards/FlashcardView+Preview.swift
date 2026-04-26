import SwiftData
import SwiftUI

struct FlashcardPreviewHost: View {
    @StateObject private var appState = AppState()

    private static let previewContainer: ModelContainer = {
        let schema = Schema([VocabularyWord.self, GrammarRule.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        // swiftlint:disable:next force_try
        try! DataSeeder(context: context).seedIfNeeded(records: DataSeeder.starterVocabulary)
        return container
    }()

    var body: some View {
        NavigationStack {
            FlashcardView(level: .a1)
                .environmentObject(appState)
                .modelContainer(Self.previewContainer)
                .onAppear {
                    appState.currentLevel = .a1
                }
        }
    }
}
