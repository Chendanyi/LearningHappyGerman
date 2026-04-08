import XCTest
import SwiftData
@testable import LearnHappyGerman

/// Evaluator: lobby level filtering vs `initial_data.json`, and German answer normalization (umlauts, ß).
final class FlashcardRegressionTests: XCTestCase {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([VocabularyWord.self, GrammarRule.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Mirrors `FlashcardView.reloadVocabulary()` when a CEFR level is selected in the lobby.
    private func wordsForLobbyLevel(_ all: [VocabularyWord], level: CEFRLevel) -> [VocabularyWord] {
        all.filter { $0.level == level.rawValue }
    }

    private func bundleContainingInitialDataJSON() -> Bundle? {
        let candidates: [Bundle] = [Bundle(for: VocabularyWord.self), Bundle.main] + Bundle.allBundles
        return candidates.first { $0.url(forResource: "initial_data", withExtension: "json") != nil }
    }

    func testLobbyA1SelectionFiltersToInitialDataA1CorpusOnly() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = LocalSeeder(context: context)
        let inserted = try seeder.mergeInitialDataFromBundle()
        XCTAssertGreaterThan(
            inserted,
            0,
            "Test host must ship initial_data.json so merge inserts rows (integration with bundle)."
        )

        let distractor = VocabularyWord(
            germanWord: "RegressionA2Only",
            article: "das",
            englishTranslation: "audit",
            level: "A2",
            category: "Noun"
        )
        context.insert(distractor)
        try context.save()

        let allRows = try context.fetch(FetchDescriptor<VocabularyWord>(sortBy: [SortDescriptor(\.germanWord)]))
        let a1Only = wordsForLobbyLevel(allRows, level: .a1)

        XCTAssertTrue(a1Only.allSatisfy { $0.level == CEFRLevel.a1.rawValue })
        XCTAssertFalse(a1Only.contains { $0.germanWord == distractor.germanWord })

        let bundle = try XCTUnwrap(bundleContainingInitialDataJSON())
        let url = try XCTUnwrap(bundle.url(forResource: "initial_data", withExtension: "json"))
        let payload = try JSONDecoder().decode(InitialDataRegressionPayload.self, from: Data(contentsOf: url))
        XCTAssertEqual(
            a1Only.count,
            payload.words.count,
            "After merge, A1-filtered count should match initial_data.json word count (no A2 leak)."
        )
    }

    func testGermanAnswerNormalizationTreatsUmlautsAsEquivalent() {
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("der Käse"),
            GermanFlashcardAnswerNormalization.normalized("DER KASE")
        )
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("die Tür"),
            GermanFlashcardAnswerNormalization.normalized("Die TUR")
        )
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("  der Öl  "),
            GermanFlashcardAnswerNormalization.normalized("der ol")
        )
    }

    func testGermanAnswerNormalizationMapsEszettForComparison() {
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("Straße"),
            GermanFlashcardAnswerNormalization.normalized("strasse")
        )
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("der Fußball"),
            GermanFlashcardAnswerNormalization.normalized("der fussball")
        )
        XCTAssertEqual(
            GermanFlashcardAnswerNormalization.normalized("GROẞE"),
            GermanFlashcardAnswerNormalization.normalized("grosse")
        )
    }
}

private struct InitialDataRegressionPayload: Codable {
    let version: Int
    let words: [InitialDataRegressionWord]
}

private struct InitialDataRegressionWord: Codable {
    let germanWord: String
    let level: String
}
