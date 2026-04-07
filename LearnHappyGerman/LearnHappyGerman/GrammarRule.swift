import Foundation
import SwiftData

/// Grammar content (tenses, conjugation patterns, usage rules) stored alongside vocabulary.
/// Optional `relatedWord` links a rule to a specific headword (e.g. a verb and its conjugation pattern).
@Model
final class GrammarRule {
    var title: String
    /// Long-form tense or concept explanation for learners.
    var explanation: String
    /// Example sentences or conjugation tables as plain text (or newline-separated lines).
    var examples: String
    /// Formal rule text (patterns, auxiliary choice, word order, etc.).
    var ruleText: String
    /// Optional CEFR scope (`"A1"`…`"C2"`). Stored as `String?` because SwiftData can reject optional persisted enums.
    var applicableLevelCode: String?
    /// Optional link to a vocabulary item (e.g. verb ↔ conjugation rule).
    @Relationship(inverse: \VocabularyWord.grammarRules)
    var relatedWord: VocabularyWord?

    init(
        title: String,
        explanation: String,
        examples: String,
        ruleText: String,
        applicableLevel: CEFRLevel? = nil,
        relatedWord: VocabularyWord? = nil
    ) {
        self.title = title
        self.explanation = explanation
        self.examples = examples
        self.ruleText = ruleText
        self.applicableLevelCode = applicableLevel?.rawValue
        self.relatedWord = relatedWord
    }
}

extension GrammarRule {
    /// Convenience for planner-level APIs that still use `CEFRLevel`.
    var applicableLevel: CEFRLevel? {
        get { applicableLevelCode.flatMap { CEFRLevel(rawValue: $0) } }
        set { applicableLevelCode = newValue?.rawValue }
    }
}
