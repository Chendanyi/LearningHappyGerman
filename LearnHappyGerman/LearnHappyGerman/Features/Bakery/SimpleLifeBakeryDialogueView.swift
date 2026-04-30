import SwiftUI

/// A1-only multi-turn “Bakery” scenario (present tense, scripted clerk lines).
struct SimpleLifeBakeryDialogueView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var engine = BakeryScenarioEngine()

    @State private var orderLine = "Zwei Brötchen, bitte."
    @State private var extraLine = "Nein, danke."
    @State private var priceLine = "Was kostet das?"

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink.ignoresSafeArea()

            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(alignment: .center, spacing: 16) {
                    Text("Simple Life — Bäckerei")
                        .font(Theme.Typography.rounded(.title2, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .frame(maxWidth: .infinity)

                    if appState.currentLevel != .a1 {
                        Text("Dieses Szenario ist für A1. Bitte wählen Sie A1 in der Lobby.")
                            .font(Theme.Typography.rounded(.body, weight: .medium))
                            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                            .multilineTextAlignment(.center)
                    } else {
                        dialogueColumn
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Theme.Colors.paperOverlay.opacity(0.42))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.Colors.societyBlue.opacity(0.9), lineWidth: 2)
                )
            }
        }
        .navigationTitle("AI Dialogue")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if appState.currentLevel == .a1 {
                engine.startScenario()
            }
        }
        .onChange(of: appState.currentLevel) {
            if appState.currentLevel == .a1 {
                engine.startScenario()
            }
        }
    }

    private var dialogueColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(engine.turns, id: \.id) { turn in
                        HStack(alignment: .top) {
                            Text(turn.isUser ? "Sie" : "Verkäufer")
                                .font(Theme.Typography.rounded(.caption, weight: .semibold))
                                .foregroundStyle(Theme.Colors.societyBlue)
                                .frame(width: 72, alignment: .leading)
                            Text(turn.text)
                                .font(Theme.Typography.rounded(.body, weight: .medium))
                                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 160)

            Group {
                if engine.canEnterOrder {
                    bakeryField(title: "Bestellung", text: $orderLine, actionTitle: "Bestellen") {
                        engine.submitOrder(orderLine)
                    }
                } else if engine.canAnswerExtra {
                    bakeryField(title: "Antwort", text: $extraLine, actionTitle: "Senden") {
                        engine.submitExtraAnswer(extraLine)
                    }
                } else if engine.canAskPrice {
                    bakeryField(title: "Preis", text: $priceLine, actionTitle: "Fragen") {
                        engine.submitPriceQuestion(priceLine)
                    }
                } else {
                    Text("Dialog zu Ende. Guten Appetit!")
                        .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private func bakeryField(
        title: String,
        text: Binding<String>,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.Typography.rounded(.caption, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.85))
            TextField("", text: text, axis: .vertical)
                .font(Theme.Typography.rounded(.body, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.Colors.societyBlue.opacity(0.35))
                )
                .lineLimit(2 ... 4)
            Button(actionTitle, action: action)
                .font(Theme.Typography.rounded(.headline, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.Colors.paperOverlay.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                )
                .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        SimpleLifeBakeryDialogueView()
            .environmentObject(AppState())
    }
}
