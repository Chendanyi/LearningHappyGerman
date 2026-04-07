import Foundation
import SwiftData

@Model
final class GrammarRule {
    @Attribute(.unique) var id: UUID
    var title: String
    var explanation: String
    /// CEFR band label, e.g. `A1`…`C2`.
    var level: String
    var exampleSentences: [String]

    init(
        id: UUID = UUID(),
        title: String,
        explanation: String,
        level: String,
        exampleSentences: [String]
    ) {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.level = level
        self.exampleSentences = exampleSentences
    }
}
