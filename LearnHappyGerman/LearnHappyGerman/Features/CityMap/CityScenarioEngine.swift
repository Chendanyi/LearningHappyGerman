import Foundation

/// AI-driven multi-turn dialogue for any CityWalk location (Gemini + A1/A2 constraints).
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

    /// Fixed ceiling so sessions cannot loop forever or exhaust quota silently.
    private static let maxUserTurns = 24

    private let config: ScenarioConfig
    private let aiClient: CityScenarioAIClient

    /// Full conversation transcript (user + AI), shown in the UI.
    @Published private(set) var conversationHistory: [ChatTurn] = []

    /// Alias for existing UI/tests expecting `turns`.
    var turns: [ChatTurn] { conversationHistory }

    @Published private(set) var isAwaitingAI: Bool = false
    @Published private(set) var isComplete: Bool = false
    @Published private(set) var lastErrorMessage: String?

    private var userTurnCount: Int = 0

    init(config: ScenarioConfig, aiClient: CityScenarioAIClient = LiveGenerativeAIClient()) {
        self.config = config
        self.aiClient = aiClient
        #if DEBUG
        print("DEBUG: Engine initialized for \(config.locationID.rawValue)")
        print("DEBUG: Initial greeting from config: \(config.initialGreeting)")

        let instruction = ScenarioPromptProvider.fullSystemInstruction(for: config.locationID)
        print("DEBUG: System instruction prepared (length): \(instruction.count)")
        #endif
    }

    func startScenario() {
        conversationHistory = [ChatTurn(isUser: false, text: config.initialGreeting)]
        #if DEBUG
        print("DEBUG: Transcript seeded with initial greeting: \(config.initialGreeting)")
        #endif
        isComplete = false
        isAwaitingAI = false
        lastErrorMessage = nil
        userTurnCount = 0
    }

    /// Sends the learner line to Gemini with system instruction + full transcript + A1/A2 rules.
    func submitUserLine(_ line: String) async {
        guard !isComplete else { return }
        guard !isAwaitingAI else { return }

        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        lastErrorMessage = nil

        guard userTurnCount < Self.maxUserTurns else {
            isComplete = true
            return
        }

        conversationHistory.append(ChatTurn(isUser: true, text: trimmed))
        userTurnCount += 1

        isAwaitingAI = true
        defer { isAwaitingAI = false }

        let systemInstruction = Self.fullSystemInstruction(for: config)
        let prompt = Self.userPrompt(config: config, history: conversationHistory)
        #if DEBUG
        let summary =
            "location=\(config.locationID.rawValue) userTurn=\(userTurnCount) " +
            "userLine=\"\(trimmed.prefix(100))\""
        Self.debugLogGeminiRequest(
            summaryLine: summary,
            prompt: prompt,
            systemInstruction: systemInstruction,
            aiClientType: String(describing: type(of: aiClient))
        )
        #endif

        do {
            let reply = try await aiClient.generateAIResponse(
                prompt: prompt,
                systemInstruction: systemInstruction
            )
            let cleaned = reply.trimmingCharacters(in: .whitespacesAndNewlines)
            #if DEBUG
            Self.debugLogGeminiResponse(cleaned: cleaned)
            #endif
            if !cleaned.isEmpty {
                conversationHistory.append(ChatTurn(isUser: false, text: cleaned))
            }
        } catch {
            #if DEBUG
            Self.debugLogGeminiError(error)
            #endif
            lastErrorMessage = "KI-Antwort nicht möglich. Bitte später erneut versuchen."
            _ = conversationHistory.popLast()
            userTurnCount -= 1
        }
    }

    #if DEBUG
    private static func debugLogGeminiRequest(
        summaryLine: String,
        prompt: String,
        systemInstruction: String,
        aiClientType: String
    ) {
        print("DEBUG: AI request — \(summaryLine)")
        print(
            "DEBUG: AI request — promptChars=\(prompt.count) " +
                "systemInstructionChars=\(systemInstruction.count) " +
                "aiClient=\(aiClientType)"
        )
    }

    private static func debugLogGeminiResponse(cleaned: String) {
        if cleaned.isEmpty {
            print("DEBUG: AI response — empty after trimming whitespace")
        } else {
            print(
                "DEBUG: AI response — chars=\(cleaned.count) " +
                    "preview=\"\(cleaned.prefix(150))\""
            )
        }
    }

    private static func debugLogGeminiError(_ error: Error) {
        print("DEBUG: AI error — \(String(describing: error))")
    }
    #endif

    var canSubmit: Bool {
        !isComplete && !isAwaitingAI
    }

    var suggestedUserPhrase: String {
        ""
    }

    private static func fullSystemInstruction(for config: ScenarioConfig) -> String {
        ScenarioPromptProvider.fullSystemInstruction(for: config.locationID)
    }

    private static func userPrompt(config: ScenarioConfig, history: [ChatTurn]) -> String {
        var lines: [String] = []
        lines.append(
            "Konversation (Rollenübung). Die letzte Zeile ist vom Lernenden und braucht deine " +
                "Antwort als \(config.clerkRoleLabel)."
        )
        lines.append("")
        for turn in history {
            let label = transcriptLabel(config: config, isUser: turn.isUser)
            lines.append("\(label): \(turn.text)")
        }
        lines.append("")
        lines.append("Antworte jetzt nur mit der nächsten Äußerung von \(config.clerkRoleLabel), ohne Meta-Kommentar.")
        return lines.joined(separator: "\n")
    }

    private static func transcriptLabel(config: ScenarioConfig, isUser: Bool) -> String {
        if isUser {
            return config.locationID == .school ? "Du (Lernende/r)" : "Sie (Lernende/r)"
        }
        return config.clerkRoleLabel
    }
}
