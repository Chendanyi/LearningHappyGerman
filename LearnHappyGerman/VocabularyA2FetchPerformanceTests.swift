import XCTest
import SwiftData
@testable import LearnHappyGerman

/// Evaluator: SwiftData fetch latency for A2 band after corpus expansion.
final class VocabularyA2FetchPerformanceTests: XCTestCase {
    func testFetchA2WordsUnderReasonableTime() throws {
        let schema = Schema([VocabularyWord.self, GrammarRule.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)

        // Synthetic 500 A2 rows (mirrors production scale; avoids test-bundle JSON coupling).
        for index in 0 ..< 500 {
            let word = VocabularyWord(
                germanWord: "LeitungsTest\(index)",
                article: "die",
                englishTranslation: "perf row \(index)",
                level: "A2",
                category: "Workplace",
                pluralSuffix: "-en",
                exampleSentence: "Die LeitungsTest\(index) ist im Büro."
            )
            context.insert(word)
        }
        try context.save()

        measure {
            let descriptor = FetchDescriptor<VocabularyWord>(
                predicate: #Predicate { $0.level == "A2" }
            )
            _ = try? context.fetch(descriptor)
        }
    }
}
