import XCTest
import SwiftData
@testable import LearnHappyGerman

/// Evaluator suite: invariants for seeded vocabulary (articles, CEFR levels, idempotent seeding).
final class VocabularyDataIntegrityTests: XCTestCase {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([VocabularyWord.self, GrammarRule.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    func testEveryNounInSeededStoreHasNonEmptyArticle() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = DataSeeder(context: context)
        try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)

        let words = try context.fetch(FetchDescriptor<VocabularyWord>())
        let nouns = words.filter { $0.category.caseInsensitiveCompare("Noun") == .orderedSame }
        XCTAssertFalse(nouns.isEmpty, "Sanity: starter data should include nouns.")

        for noun in nouns {
            XCTAssertTrue(
                noun.hasValidArticleForNoun,
                "Noun '\(noun.germanWord)' must have der/die/das (model rule)."
            )
            let trimmed = noun.article?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            XCTAssertFalse(trimmed.isEmpty, "Noun '\(noun.germanWord)' must have a non-empty article field.")
            XCTAssertNotEqual(
                trimmed.lowercased(),
                "none",
                "Noun '\(noun.germanWord)' must not use 'none' as article."
            )
        }
    }

    func testEverySeededWordHasValidCEFRLevel() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = DataSeeder(context: context)
        try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)

        let words = try context.fetch(FetchDescriptor<VocabularyWord>())
        let validCodes = CEFRLevel.validLevelCodes

        for word in words {
            XCTAssertTrue(
                validCodes.contains(word.level),
                "Word '\(word.germanWord)' has invalid CEFR level '\(word.level)' (expected A1–C2)."
            )
            XCTAssertTrue(
                CEFRLevel.isValidLevelCode(word.level),
                "CEFRLevel.isValidLevelCode must accept persisted level '\(word.level)'."
            )
        }
    }

    func testDataSeederSeedIfNeededDoesNotDuplicateOnSecondRun() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = DataSeeder(context: context)

        try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)
        let countAfterFirst = try context.fetchCount(FetchDescriptor<VocabularyWord>())
        let wordsFirst = try context.fetch(FetchDescriptor<VocabularyWord>())
        let keysFirst = Set(wordsFirst.map { "\($0.germanWord)|\($0.level)" })

        try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)
        let countAfterSecond = try context.fetchCount(FetchDescriptor<VocabularyWord>())
        let wordsSecond = try context.fetch(FetchDescriptor<VocabularyWord>())
        let keysSecond = Set(wordsSecond.map { "\($0.germanWord)|\($0.level)" })

        XCTAssertEqual(
            countAfterFirst,
            countAfterSecond,
            "Running seedIfNeeded twice must not insert duplicate vocabulary rows (upsert / empty-store guard)."
        )
        XCTAssertEqual(countAfterFirst, DataSeeder.starterVocabulary.count)
        XCTAssertEqual(keysFirst.count, keysSecond.count)
        XCTAssertEqual(keysFirst, keysSecond, "Stable (germanWord, level) keys must not change after second seed pass.")
    }
}
