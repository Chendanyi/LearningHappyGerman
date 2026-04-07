import Foundation
import SwiftData

// MARK: - UI / routing (not persisted)

/// CEFR labels for lobby and filters; persisted `VocabularyWord.level` is a matching `String` (e.g. `"A1"`).
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

    /// Codes persisted on `VocabularyWord.level` (queries / integrity tests).
    static let validLevelCodes: Set<String> = Set(allCases.map(\.rawValue))

    static func isValidLevelCode(_ code: String) -> Bool {
        validLevelCodes.contains(code)
    }
}

// MARK: - SwiftData

@Model
final class VocabularyWord {
    #Index<VocabularyWord>([\.germanWord], [\.level])
    @Attribute(.unique) var id: UUID
    var germanWord: String
    /// `der` / `die` / `das`, or `nil` / `"none"` when no article applies (verbs, adjectives).
    var article: String?
    var englishTranslation: String
    /// CEFR band as plain text, e.g. `A1`…`C2` (indexed for queries).
    var level: String
    /// Domain or part-of-speech tag, e.g. `Bakery`, `Office`, `Noun`.
    var category: String
    var isMastered: Bool
    var version: Int

    init(
        id: UUID = UUID(),
        germanWord: String,
        article: String?,
        englishTranslation: String,
        level: String,
        category: String,
        isMastered: Bool = false,
        version: Int = 1
    ) {
        self.id = id
        self.germanWord = germanWord
        self.article = article
        self.englishTranslation = englishTranslation
        self.level = level
        self.category = category
        self.isMastered = isMastered
        self.version = version
    }
}

extension VocabularyWord {
    /// POS buckets that do not take a definite article in the stored lemma (verbs, etc.).
    static let categoriesWithoutArticle: Set<String> = [
        "verb", "adjective", "adverb", "phrase", "expression", "other"
    ]

    /// Words that take **der/die/das** in German (nouns and thematic buckets like “Daily Life”, “Travel”).
    var requiresGermanArticle: Bool {
        !Self.categoriesWithoutArticle.contains(category.lowercased())
    }

    /// Rows that need an article must carry der/die/das (not `none` / empty).
    var hasValidArticleForNoun: Bool {
        guard requiresGermanArticle else { return true }
        guard let art = normalizedArticle else { return false }
        return art == "der" || art == "die" || art == "das"
    }

    /// Collapses `"none"` and blanks to `nil` for checks.
    private var normalizedArticle: String? {
        guard let article else { return nil }
        let trimmed = article.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.lowercased() == "none" { return nil }
        return trimmed.lowercased()
    }
}
