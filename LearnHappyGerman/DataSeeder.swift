import Foundation
import SwiftData

struct VocabularySeedRecord: Codable {
    let germanWord: String
    let article: String?
    let englishTranslation: String
    let level: String
    let category: String
}

final class DataSeeder {
    private let context: ModelContext

    static let starterVocabulary: [VocabularySeedRecord] = [
        .init(
            germanWord: "Apfel",
            article: "der",
            englishTranslation: "apple",
            level: "A1",
            category: "Noun"
        ),
        .init(
            germanWord: "Buch",
            article: "das",
            englishTranslation: "book",
            level: "A1",
            category: "Noun"
        ),
        .init(
            germanWord: "Bahnhof",
            article: "der",
            englishTranslation: "station",
            level: "A2",
            category: "Noun"
        ),
        .init(
            germanWord: "lernen",
            article: nil,
            englishTranslation: "to learn",
            level: "B1",
            category: "Verb"
        ),
        .init(
            germanWord: "Rechnung",
            article: "die",
            englishTranslation: "invoice",
            level: "B2",
            category: "Noun"
        ),
        .init(
            germanWord: "vorzüglich",
            article: nil,
            englishTranslation: "excellent",
            level: "C1",
            category: "Adjective"
        ),
        .init(
            germanWord: "Weltanschauung",
            article: "die",
            englishTranslation: "worldview",
            level: "C2",
            category: "Noun"
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
                germanWord: record.germanWord,
                article: record.article,
                englishTranslation: record.englishTranslation,
                level: record.level,
                category: record.category
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
}
