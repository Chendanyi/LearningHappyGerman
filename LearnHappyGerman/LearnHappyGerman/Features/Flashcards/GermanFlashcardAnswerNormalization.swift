import Foundation

/// Normalization for flashcard typed answers vs expected German lemmas.
/// Uses `de_DE` folding for umlauts and maps **ß / ẞ → ss** so `Straße` matches `strasse`.
enum GermanFlashcardAnswerNormalization {
    private static let comparisonLocale = Locale(identifier: "de_DE")

    static func normalized(_ value: String) -> String {
        var trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmed = trimmed.replacingOccurrences(of: "\u{00df}", with: "ss", options: .literal)
        trimmed = trimmed.replacingOccurrences(of: "\u{1e9e}", with: "ss", options: .literal)
        return trimmed
            .folding(options: .diacriticInsensitive, locale: comparisonLocale)
            .lowercased()
    }
}
