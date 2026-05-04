import Foundation

/// Supplies the Gemini API key from **Info.plist** only — never hardcoded in Swift.
///
/// Build pipeline: `Secrets.xcconfig` (gitignored) sets **`GOOGLE_AI_API_KEY`**; tracked
/// **`AppInfoAdditions.plist`** includes `$(GOOGLE_AI_API_KEY)` and is merged with the
/// generated plist via **`INFOPLIST_FILE`**. `AppSecrets.xcconfig` `#include?` **Secrets**.
/// Runtime reads **`GOOGLE_AI_API_KEY`** from **`Bundle.main`**.
enum GoogleGenerativeAIConfiguration {

    /// Google AI model id for `generateContent`.
    /// Must match a model your API key supports (e.g. Gemini 2.5 Flash on Google AI Studio).
    static let defaultGenerativeModelName = "gemini-2.5-flash"

    /// Must match `INFOPLIST_KEY_*` → Info.plist key for generated plist (see `AppSecrets.xcconfig`).
    static let infoDictionaryKey = "GOOGLE_AI_API_KEY"

    /// Trimmed API key, or `nil` if missing, empty, or placeholder.
    static var googleAIAPIKey: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if isPlaceholder(trimmed) { return nil }
        return trimmed
    }

    private static func isPlaceholder(_ value: String) -> Bool {
        let upper = value.uppercased()
        return upper == "YOUR_API_KEY_HERE" || upper == "$(GOOGLE_AI_API_KEY)"
    }
}

enum GoogleGenerativeAIConfigurationError: Error {
    case missingOrInvalidAPIKey
}
