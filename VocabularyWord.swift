import Foundation
import SwiftData

enum GermanArticle: String, Codable, CaseIterable {
    case der
    case die
    case das
    case none
}

enum CEFRLevel: String, Codable, CaseIterable, Comparable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    private var rank: Int {
        switch self {
        case .a1: return 1
        case .a2: return 2
        case .b1: return 3
        case .b2: return 4
        case .c1: return 5
        case .c2: return 6
        }
    }

    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        lhs.rank < rhs.rank
    }
}

enum WordCategory: String, Codable, CaseIterable {
    case noun = "Noun"
    case verb = "Verb"
    case adjective = "Adjective"
    case adverb = "Adverb"
    case phrase = "Phrase"
    case expression = "Expression"
    case other = "Other"
}

@Model
final class VocabularyWord {
    var germanWord: String
    var article: GermanArticle
    var englishTranslation: String
    var level: CEFRLevel
    var category: WordCategory
    var isMastered: Bool

    init(
        germanWord: String,
        article: GermanArticle = .none,
        englishTranslation: String,
        level: CEFRLevel,
        category: WordCategory,
        isMastered: Bool = false
    ) {
        self.germanWord = germanWord
        self.article = article
        self.englishTranslation = englishTranslation
        self.level = level
        self.category = category
        self.isMastered = isMastered
    }
}

extension VocabularyWord {
    var hasValidArticleForNoun: Bool {
        guard category == .noun else { return true }
        return article != .none
    }
}
