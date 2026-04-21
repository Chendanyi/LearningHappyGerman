import XCTest
import SwiftData
@testable import LearnHappyGerman

/// Evaluator: lobby level filtering vs `german_vocabulary.json`, and German answer normalization (umlauts, ß).
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

    private func bundleContainingGermanVocabularyJSON() -> Bundle? {
        let candidates: [Bundle] = [Bundle(for: VocabularyWord.self), Bundle.main] + Bundle.allBundles
        return candidates.first { $0.url(forResource: "german_vocabulary", withExtension: "json") != nil }
    }

    func testLobbyA1SelectionFiltersToGermanVocabularyA1CorpusOnly() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = LocalSeeder(context: context)
        let mergeResult = try seeder.mergeGermanVocabularyFromBundle()
        XCTAssertGreaterThan(
            mergeResult.inserted,
            0,
            "Test host must ship german_vocabulary.json so merge inserts rows (integration with bundle)."
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

        let bundle = try XCTUnwrap(bundleContainingGermanVocabularyJSON())
        let url = try XCTUnwrap(bundle.url(forResource: "german_vocabulary", withExtension: "json"))
        let payload = try JSONDecoder().decode([GermanVocabRegressionRecord].self, from: Data(contentsOf: url))
        let a1Count = payload.filter { $0.level == "A1" }.count
        XCTAssertEqual(
            a1Only.count,
            a1Count,
            "After merge, A1-filtered count should match german_vocabulary.json A1 rows (no A2 leak)."
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

private struct GermanVocabRegressionRecord: Codable {
    let word: String
    let level: String
}
