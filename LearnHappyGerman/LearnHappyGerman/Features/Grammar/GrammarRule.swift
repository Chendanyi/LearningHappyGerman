import Foundation
import SwiftData

@Model
final class GrammarRule {
    @Attribute(.unique) var id: UUID
    /// Module grouping, e.g. `Sentence Structure`, `Verbs`.
    var module: String
    var title: String
    /// German grammar term (e.g. `Verbzweitstellung`).
    var germanTitle: String
    /// Structural pattern string for the rule.
    var formula: String
    /// Concise English explanation (from bundled `description`).
    var explanation: String
    /// Simplified Chinese explanation (from bundled `description_cn`).
    var descriptionCN: String
    /// CEFR band label, e.g. `A1`…`C2`.
    var level: String
    /// Example German lines (same length as `exampleEnglishLines`).
    var exampleGermanLines: [String]
    /// Example English lines (same length as `exampleGermanLines`).
    var exampleEnglishLines: [String]

    init(
        id: UUID = UUID(),
        module: String = "",
        title: String,
        germanTitle: String = "",
        formula: String = "",
        explanation: String,
        descriptionCN: String = "",
        level: String,
        exampleGermanLines: [String] = [],
        exampleEnglishLines: [String] = []
    ) {
        self.id = id
        self.module = module
        self.title = title
        self.germanTitle = germanTitle
        self.formula = formula
        self.explanation = explanation
        self.descriptionCN = descriptionCN
        self.level = level
        self.exampleGermanLines = exampleGermanLines
        self.exampleEnglishLines = exampleEnglishLines
    }
}
