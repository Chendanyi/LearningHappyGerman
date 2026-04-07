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

    // MARK: - initial_data.json (A1 corpus in app bundle)

    func testInitialDataJSONPassesArticleAndLevelIntegrity() throws {
        let bundle = try XCTUnwrap(
            Self.bundleContainingInitialDataJSON(),
            "initial_data.json must be in the app target bundle (Copy Bundle Resources)."
        )
        let url = try XCTUnwrap(
            bundle.url(forResource: "initial_data", withExtension: "json"),
            "initial_data.json URL missing in bundle \(bundle.bundlePath)."
        )
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(InitialDataPayload.self, from: data)

        XCTAssertEqual(payload.words.count, 30, "A1 initial corpus must contain 30 entries.")
        XCTAssertEqual(Set(payload.words.map(\.id)).count, 30, "Each row needs a unique id (UUID).")
        XCTAssertEqual(
            Set(payload.words.map { "\($0.germanWord)|\($0.level)" }).count,
            30,
            "Each row needs a unique (germanWord, level) pair."
        )

        for dto in payload.words {
            XCTAssertEqual(dto.level, "A1")
            XCTAssertTrue(CEFRLevel.isValidLevelCode(dto.level))

            let articleOpt = Self.normalizedArticleFromJSON(dto.article)
            if dto.article.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "none",
               dto.article.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "" {
                XCTAssertNotNil(
                    articleOpt,
                    "Article for '\(dto.germanWord)' must be der, die, das, or none."
                )
            }

            let word = VocabularyWord(
                id: dto.id,
                germanWord: dto.germanWord,
                article: articleOpt,
                englishTranslation: dto.englishTranslation,
                level: dto.level,
                category: dto.category,
                isMastered: dto.isMastered ?? false,
                version: dto.version ?? 1
            )
            XCTAssertTrue(
                word.hasValidArticleForNoun,
                "Integrity: nouns/thematic entries must have der/die/das; verbs use category Verb with article none (\(dto.germanWord))."
            )
        }
    }

    private static func normalizedArticleFromJSON(_ raw: String) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if t.isEmpty || t == "none" { return nil }
        guard t == "der" || t == "die" || t == "das" else { return nil }
        return t
    }

    /// Unit tests may resolve `Bundle(for:)` differently than the host app; prefer any bundle that ships `initial_data.json`.
    private static func bundleContainingInitialDataJSON() -> Bundle? {
        let candidates: [Bundle] = [Bundle(for: VocabularyWord.self), Bundle.main] + Bundle.allBundles
        return candidates.first { $0.url(forResource: "initial_data", withExtension: "json") != nil }
    }
}

private struct InitialDataPayload: Codable {
    let version: Int
    let words: [InitialDataWordRecord]
}

private struct InitialDataWordRecord: Codable {
    let id: UUID
    let germanWord: String
    let article: String
    let englishTranslation: String
    let level: String
    let category: String
    let isMastered: Bool?
    let version: Int?
}
