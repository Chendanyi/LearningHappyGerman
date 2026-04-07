import Foundation
import SwiftData

struct VocabularySeedRecord: Codable {
    let germanWord: String
    let article: GermanArticle
    let englishTranslation: String
    let level: CEFRLevel
    let category: WordCategory
}

final class DataSeeder {
    private let context: ModelContext

    static let starterVocabulary: [VocabularySeedRecord] = [
        .init(
            germanWord: "Apfel",
            article: .der,
            englishTranslation: "apple",
            level: .a1,
            category: .noun
        ),
        .init(
            germanWord: "Buch",
            article: .das,
            englishTranslation: "book",
            level: .a1,
            category: .noun
        ),
        .init(
            germanWord: "Bahnhof",
            article: .der,
            englishTranslation: "station",
            level: .a2,
            category: .noun
        ),
        .init(
            germanWord: "lernen",
            article: .none,
            englishTranslation: "to learn",
            level: .b1,
            category: .verb
        ),
        .init(
            germanWord: "Rechnung",
            article: .die,
            englishTranslation: "invoice",
            level: .b2,
            category: .noun
        ),
        .init(
            germanWord: "vorzüglich",
            article: .none,
            englishTranslation: "excellent",
            level: .c1,
            category: .adjective
        ),
        .init(
            germanWord: "Weltanschauung",
            article: .die,
            englishTranslation: "worldview",
            level: .c2,
            category: .noun
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
        let filtered = records.filter { $0.level == level }
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
