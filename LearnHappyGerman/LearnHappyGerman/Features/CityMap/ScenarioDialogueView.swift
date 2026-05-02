import SwiftUI
import UIKit

/// Multi-location A1/A2 scripted dialogue (content from `ScenarioCatalog`).
struct ScenarioDialogueView: View {
    let building: CityMapHotspotLayout.Building

    @EnvironmentObject private var appState: AppState
    @StateObject private var engine: CityScenarioEngine
    @State private var userLine: String = ""

    init(building: CityMapHotspotLayout.Building) {
        self.building = building
        let config = ScenarioCatalog.config(for: building)
        _engine = StateObject(wrappedValue: CityScenarioEngine(config: config))
    }

    private var config: ScenarioConfig {
        ScenarioCatalog.config(for: building)
    }

    private var canPlayScenario: Bool {
        guard let level = appState.currentLevel else { return false }
        return level == .a1 || level == .a2
    }

    var body: some View {
        ZStack {
            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(alignment: .center, spacing: 16) {
                    scenarioHeader
                    topicVocabularyRow

                    if !canPlayScenario {
                        Text(
                            "Dieses Szenario ist für A1 und A2. "
                                + "Bitte wählen Sie A1 oder A2 in der Lobby."
                        )
                        .font(Theme.Typography.body(.body, weight: .regular))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                    } else {
                        dialogueColumn
                    }
                }
                .padding(24)
                .vintageCard()
            }
        }
        .vintageScreenBackground()
        .navigationTitle(building.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if canPlayScenario {
                engine.startScenario()
                userLine = engine.suggestedUserPhrase
            }
        }
        .onChange(of: appState.currentLevel) {
            if canPlayScenario {
                engine.startScenario()
                userLine = engine.suggestedUserPhrase
            }
        }
    }

    private var scenarioHeader: some View {
        VStack(spacing: 12) {
            scenarioHeroImage
            Text(building.rawValue.uppercased())
                .font(Theme.Typography.rounded(.title2, weight: .medium))
                .tracking(0.9)
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var scenarioHeroImage: some View {
        Group {
            if let name = config.backgroundImageName,
               UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.Colors.societyBlue.opacity(0.35), lineWidth: 1)
                    )
            } else {
                Image(systemName: config.symbolName)
                    .font(.system(size: 56, weight: .ultraLight))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .symbolRenderingMode(.hierarchical)
                    .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Szenario \(building.rawValue)")
    }

    private var topicVocabularyRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Themenwortschatz")
                .font(Theme.Typography.body(.caption, weight: .semibold))
                .foregroundStyle(Theme.Colors.deepBrown)
            FlowTopicWrap(words: config.topicVocabulary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dialogueColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(engine.turns, id: \.id) { turn in
                        HStack(alignment: .top) {
                            Text(turn.isUser ? (building == .school ? "Du" : "Sie") : config.clerkRoleLabel)
                                .font(Theme.Typography.rounded(.caption, weight: .semibold))
                                .foregroundStyle(Theme.Colors.accentUI)
                                .frame(width: 88, alignment: .leading)
                            Text(turn.text)
                                .font(Theme.Typography.body(.body, weight: .regular))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 160)

            if engine.canSubmit {
                inputColumn
            } else if engine.isComplete {
                Text("Dialog zu Ende.")
                    .font(Theme.Typography.body(.subheadline, weight: .regular))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var inputColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ihre Antwort")
                .font(Theme.Typography.body(.caption, weight: .regular))
                .foregroundStyle(Theme.Colors.deepBrown)
            TextField("A1/A2 Antwort", text: $userLine, axis: .vertical)
                .font(Theme.Typography.rounded(.body, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.Colors.cardHighlight)
                )
                .lineLimit(2 ... 4)
                .accessibilityIdentifier("scenario.dialogue.answerField")
            Button("Senden") {
                let countBefore = engine.turns.count
                engine.submitUserLine(userLine)
                if engine.turns.count > countBefore {
                    userLine = engine.suggestedUserPhrase
                }
            }
            .font(Theme.Typography.rounded(.headline, weight: .medium))
            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.Colors.cardHighlight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
            )
            .buttonStyle(.plain)
        }
    }
}

/// Horizontal scroll of topic chips (keeps layout simple and readable).
private struct FlowTopicWrap: View {
    let words: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                    Text(word)
                        .font(Theme.Typography.rounded(.caption, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Theme.Colors.cardHighlight)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Theme.Colors.societyBlue.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScenarioDialogueView(building: .bakery)
            .environmentObject(AppState())
    }
}
