import Foundation
import SwiftData

struct VocabularySeedPayload: Codable {
    let version: Int
    let words: [VocabularySeedRecord]
}

struct VocabularySeedRecord: Codable {
    let id: UUID?
    let germanWord: String
    let article: String?
    let englishTranslation: String
    let level: String
    let category: String
    let version: Int?
    let pluralSuffix: String?
    let exampleSentence: String?
}

final class DataSeeder {
    private let context: ModelContext

    static let starterVocabulary: [VocabularySeedRecord] = [
        .init(
            id: nil,
            germanWord: "Apfel",
            article: "der",
            englishTranslation: "apple",
            level: "A1",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "Buch",
            article: "das",
            englishTranslation: "book",
            level: "A1",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "Bahnhof",
            article: "der",
            englishTranslation: "station",
            level: "A2",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "Voraussetzung",
            article: "die",
            englishTranslation: "prerequisite",
            level: "B1",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "Rechnung",
            article: "die",
            englishTranslation: "invoice",
            level: "B2",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "vorzüglich",
            article: nil,
            englishTranslation: "excellent",
            level: "C1",
            category: "Adjective",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        ),
        .init(
            id: nil,
            germanWord: "Weltanschauung",
            article: "die",
            englishTranslation: "worldview",
            level: "C2",
            category: "Noun",
            version: 1,
            pluralSuffix: nil,
            exampleSentence: nil
        )
    ]

    init(context: ModelContext) {
        self.context = context
    }

    /// Imports records for A1...C2 in level order.
    func importA1ToC2(records: [VocabularySeedRecord]) throws {
        for level in CEFRLevel.allCases.sorted() {
            try importLevel(level, from: records)
        }
    }

    func importLevel(_ level: CEFRLevel, from records: [VocabularySeedRecord]) throws {
        let code = level.rawValue
        let filtered = records.filter { $0.level == code }
        for record in filtered {
            let word = VocabularyWord(
                id: record.id ?? UUID(),
                germanWord: record.germanWord,
                article: record.article,
                englishTranslation: record.englishTranslation,
                level: record.level,
                category: record.category,
                pluralSuffix: record.pluralSuffix,
                exampleSentence: record.exampleSentence,
                version: record.version ?? 1
            )
            context.insert(word)
        }
        try context.save()
    }

    /// Seeds only when local store is empty.
    func seedIfNeeded(records: [VocabularySeedRecord]) throws {
        let descriptor = FetchDescriptor<VocabularyWord>()
        let existing = try context.fetchCount(descriptor)
        guard existing == 0 else { return }
        try importA1ToC2(records: records)
    }

    /// Decode external vocabulary payload from either:
    /// - `{"version":1,"words":[...]}`
    /// - `[{...}, {...}]`
    static func decodeRecords(from data: Data) throws -> [VocabularySeedRecord] {
        let decoder = JSONDecoder()
        if let wrapped = try? decoder.decode(VocabularySeedPayload.self, from: data) {
            return wrapped.words
        }
        return try decoder.decode([VocabularySeedRecord].self, from: data)
    }

    /// Convenience for external JSON in `VocabularySeedPayload` / `[VocabularySeedRecord]` shape.
    func seedIfNeeded(jsonFileURL: URL) throws {
        let data = try Data(contentsOf: jsonFileURL)
        let records = try Self.decodeRecords(from: data)
        try seedIfNeeded(records: records)
    }
}
