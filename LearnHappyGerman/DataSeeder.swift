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
