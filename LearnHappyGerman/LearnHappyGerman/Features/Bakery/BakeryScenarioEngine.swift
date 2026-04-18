import Foundation

/// Logic-driven multi-turn A1 bakery dialogue (present tense only).
@MainActor
final class BakeryScenarioEngine: ObservableObject {
    enum Phase: Int, CaseIterable {
        case greet
        case afterOrder
        case afterDeclineExtra
        case done
    }

    struct Turn: Identifiable, Equatable {
        let id = UUID()
        let isUser: Bool
        let text: String
    }

    @Published private(set) var phase: Phase = .greet
    @Published private(set) var turns: [Turn] = []

    func startScenario() {
        phase = .greet
        turns = [
            Turn(isUser: false, text: "Guten Tag! Was möchten Sie?")
        ]
    }

    /// User orders items (A1 present tense).
    func submitOrder(_ line: String) {
        guard phase == .greet else { return }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        turns.append(Turn(isUser: true, text: trimmed))
        turns.append(
            Turn(
                isUser: false,
                text: "Heute gibt es ein Special: frische Brötchen. Möchten Sie noch etwas?"
            )
        )
        phase = .afterOrder
    }

    /// User answers the “noch etwas?” prompt.
    func submitExtraAnswer(_ line: String) {
        guard phase == .afterOrder else { return }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        turns.append(Turn(isUser: true, text: trimmed))
        turns.append(Turn(isUser: false, text: "Gern."))
        phase = .afterDeclineExtra
    }

    /// User asks for the total (price).
    func submitPriceQuestion(_ line: String) {
        guard phase == .afterDeclineExtra else { return }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        turns.append(Turn(isUser: true, text: trimmed))
        turns.append(
            Turn(
                isUser: false,
                text: "Das macht vier Euro fünfzig. Vielen Dank und auf Wiedersehen!"
            )
        )
        phase = .done
    }

    var canEnterOrder: Bool { phase == .greet }
    var canAnswerExtra: Bool { phase == .afterOrder }
    var canAskPrice: Bool { phase == .afterDeclineExtra }
}
