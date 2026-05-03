import Foundation

/// Data-driven multi-turn dialogue for any `ScenarioConfig` (A1/A2 scripted German).
@MainActor
final class CityScenarioEngine: ObservableObject {
    struct ChatTurn: Identifiable, Equatable {
        let id: UUID
        let isUser: Bool
        let text: String

        init(id: UUID = UUID(), isUser: Bool, text: String) {
            self.id = id
            self.isUser = isUser
            self.text = text
        }
    }

    private let config: ScenarioConfig

    @Published private(set) var turns: [ChatTurn] = []
    /// Index of the `dialogueRounds` entry we are waiting for (0 … count).
    @Published private(set) var awaitingRoundIndex: Int = 0
    @Published private(set) var isComplete: Bool = false

    init(config: ScenarioConfig) {
        self.config = config
    }

    func startScenario() {
        turns = [ChatTurn(isUser: false, text: config.initialGreeting)]
        awaitingRoundIndex = 0
        isComplete = false
    }

    /// Submit learner text for the current round. No-op if empty, complete, or phrase does not match.
    func submitUserLine(_ line: String) {
        guard !isComplete else { return }
        guard awaitingRoundIndex < config.dialogueRounds.count else { return }

        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let round = config.dialogueRounds[awaitingRoundIndex]
        guard ScenarioPhraseMatching.matches(trimmed, acceptablePhrases: round.possibleUserResponses) else {
            return
        }

        turns.append(ChatTurn(isUser: true, text: trimmed))
        turns.append(ChatTurn(isUser: false, text: round.clerkReply))
        awaitingRoundIndex += 1

        if awaitingRoundIndex >= config.dialogueRounds.count {
            if let farewell = config.farewellClerkLine?.trimmingCharacters(in: .whitespacesAndNewlines),
               !farewell.isEmpty {
                turns.append(ChatTurn(isUser: false, text: farewell))
            }
            isComplete = true
        }
    }

    var canSubmit: Bool {
        !isComplete && awaitingRoundIndex < config.dialogueRounds.count
    }

    /// First suggested phrase for the current round (UI placeholder).
    var suggestedUserPhrase: String {
        guard awaitingRoundIndex < config.dialogueRounds.count else { return "" }
        return config.dialogueRounds[awaitingRoundIndex].possibleUserResponses.first ?? ""
    }
}
