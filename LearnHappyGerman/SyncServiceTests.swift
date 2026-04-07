import XCTest
import SwiftData
@testable import LearnHappyGerman

final class SyncServiceTests: XCTestCase {
    /// Remote update changes editorial text; local mastery flag must remain unchanged.
    func testRemoteUpdatePreservesIsMastered() throws {
        let schema = Schema([VocabularyWord.self, GrammarRule.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)

        let local = VocabularyWord(
            germanWord: "Apfel",
            article: "der",
            englishTranslation: "apple",
            level: "A1",
            category: "Noun",
            isMastered: true,
            version: 1
        )
        context.insert(local)
        try context.save()

        let remoteJSON = """
        {
          "version": 2,
          "words": [
            {
              "germanWord": "Apfel",
              "article": "der",
              "englishTranslation": "apple (updated gloss)",
              "level": "A1",
              "category": "Noun",
              "version": 2
            }
          ]
        }
        """
        let data = try XCTUnwrap(remoteJSON.data(using: .utf8))
        let payload = try SyncService.decodeRemotePayload(from: data)
        let result = try SyncService.mergeRemotePayload(payload, into: context)

        XCTAssertEqual(result.insertedCount, 0, "Existing row should be updated, not inserted again.")
        XCTAssertEqual(result.updatedCount, 1)

        let fetched = try context.fetch(FetchDescriptor<VocabularyWord>())
        XCTAssertEqual(fetched.count, 1)
        let word = try XCTUnwrap(fetched.first)
        XCTAssertEqual(word.englishTranslation, "apple (updated gloss)")
        XCTAssertTrue(word.isMastered, "User mastery must survive remote definition updates.")
        XCTAssertGreaterThanOrEqual(word.version, 2)
    }
}
