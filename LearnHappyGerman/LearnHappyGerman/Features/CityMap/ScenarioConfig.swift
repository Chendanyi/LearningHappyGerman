import Foundation

/// One user–clerk exchange after `initialGreeting`: learner must match one phrase, then the clerk answers.
struct ScenarioDialogueRound: Equatable, Sendable {
    /// Expected A1/A2 learner lines (matched with normalization; see `ScenarioPhraseMatching`).
    let possibleUserResponses: [String]
    let clerkReply: String
}

/// Scripted location scenario for `CityScenarioEngine`.
struct ScenarioConfig: Equatable, Sendable {
    let locationID: CityMapHotspotLayout.Building
    /// Shown next to clerk lines (e.g. Verkäufer, Kellner).
    let clerkRoleLabel: String
    let initialGreeting: String
    let dialogueRounds: [ScenarioDialogueRound]
    let topicVocabulary: [String]
    /// Optional closing line after the last `dialogueRounds` reply.
    /// Omit when the last `clerkReply` already ends the scene.
    let farewellClerkLine: String?
    let symbolName: String
    /// Optional asset in `Assets.xcassets`; when missing, UI falls back to `symbolName`.
    let backgroundImageName: String?
}

enum ScenarioPhraseMatching {
    /// True if the learner line equals a phrase (after normalization) or contains it (phrase length ≥ 3).
    static func matches(_ userLine: String, acceptablePhrases: [String]) -> Bool {
        let normalizedUser = GermanFlashcardAnswerNormalization.normalized(userLine)
        guard !normalizedUser.isEmpty else { return false }
        for phrase in acceptablePhrases {
            let normPhrase = GermanFlashcardAnswerNormalization.normalized(phrase)
            if normPhrase.isEmpty { continue }
            if normalizedUser == normPhrase { return true }
            if normPhrase.count >= 3, normalizedUser.contains(normPhrase) { return true }
        }
        return false
    }
}
