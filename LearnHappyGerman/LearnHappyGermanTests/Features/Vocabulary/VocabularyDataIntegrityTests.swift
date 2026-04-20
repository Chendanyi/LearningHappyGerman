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

    // MARK: - german_vocabulary.json (bundled Goethe corpus)

    /// If the bundle supplies `englishTranslation` but SwiftData still has an empty gloss (legacy import),
    /// a second merge must backfill without duplicating rows.
    func testBundledMergeBackfillsEmptyEnglishFromJSON() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let seeder = LocalSeeder(context: context)
        let first = try seeder.mergeGermanVocabularyFromBundle()
        XCTAssertGreaterThan(first.inserted, 0, "Bundle merge should insert corpus rows.")

        let all = try context.fetch(FetchDescriptor<VocabularyWord>())
        guard let target = all.first(where: {
            !$0.englishTranslation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else {
            throw XCTSkip("Bundled german_vocabulary.json has no englishTranslation rows; cannot test backfill.")
        }
        let saved = target.englishTranslation
        target.englishTranslation = ""
        try context.save()

        let second = try seeder.mergeGermanVocabularyFromBundle()
        XCTAssertEqual(second.inserted, 0, "Second merge must not insert duplicates.")
        XCTAssertGreaterThan(second.updated, 0, "Second merge should restore glosses from JSON.")
        XCTAssertEqual(target.englishTranslation, saved)
    }

    func testGermanVocabularyJSONPassesArticleAndLevelIntegrity() throws {
        let bundle = try XCTUnwrap(
            Self.bundleContainingGermanVocabularyJSON(),
            "german_vocabulary.json must be in the app target bundle (Copy Bundle Resources)."
        )
        let url = try XCTUnwrap(
            bundle.url(forResource: "german_vocabulary", withExtension: "json"),
            "german_vocabulary.json URL missing in bundle \(bundle.bundlePath)."
        )
        let data = try Data(contentsOf: url)
        let records = try JSONDecoder().decode([GermanVocabIntegrityRecord].self, from: data)

        XCTAssertFalse(records.isEmpty, "Bundled Goethe vocabulary must not be empty.")

        let keys = Set(records.map { "\($0.word)|\($0.level)" })
        XCTAssertEqual(keys.count, records.count, "Each row needs a unique (word, level) pair.")

        for dto in records {
            XCTAssertTrue(CEFRLevel.isValidLevelCode(dto.level), "Invalid level for \(dto.word)")

            let category = dto.type.trimmingCharacters(in: .whitespacesAndNewlines)
            if category.lowercased() == "noun" {
                let articleOpt = Self.normalizedArticleFromJSON(dto.article ?? "none")
                XCTAssertNotNil(
                    articleOpt,
                    "Noun '\(dto.word)' must have der, die, or das in JSON."
                )
                let word = VocabularyWord(
                    germanWord: dto.word,
                    article: articleOpt,
                    englishTranslation: "",
                    level: dto.level,
                    category: "Noun",
                    pluralSuffix: nil,
                    exampleSentence: nil
                )
                XCTAssertTrue(
                    word.hasValidArticleForNoun,
                    "Noun '\(dto.word)' must validate for SwiftData import."
                )
            }
        }
    }

    private static func normalizedArticleFromJSON(_ raw: String?) -> String? {
        let trimmedArticle = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmedArticle.isEmpty || trimmedArticle == "none" { return nil }
        guard trimmedArticle == "der" || trimmedArticle == "die" || trimmedArticle == "das" else { return nil }
        return trimmedArticle
    }

    private static func bundleContainingGermanVocabularyJSON() -> Bundle? {
        let candidates: [Bundle] = [Bundle(for: VocabularyWord.self), Bundle.main] + Bundle.allBundles
        return candidates.first {
            $0.url(forResource: "german_vocabulary", withExtension: "json") != nil
        }
    }
}

private struct GermanVocabIntegrityRecord: Codable {
    let word: String
    let type: String
    let level: String
    let article: String?
}
