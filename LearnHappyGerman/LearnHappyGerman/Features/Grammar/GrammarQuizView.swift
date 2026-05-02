import SwiftUI

/// A1 present-tense fill-in (parchment card layout, societyBlue input borders).
struct GrammarQuizView: View {
    @EnvironmentObject private var appState: AppState

    @State private var templates: [SentenceTemplate] = []
    @State private var index = 0
    @State private var answer = ""
    @State private var feedback: String?
    @State private var isCorrect: Bool?

    private var current: SentenceTemplate? {
        guard index >= 0, index < templates.count else { return nil }
        return templates[index]
    }

    var body: some View {
        ZStack {
            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(spacing: 20) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .doodleSymbolStyle()

                    Text("TENSES — FILL IN THE VERB")
                        .font(Theme.Typography.rounded(.title2, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .multilineTextAlignment(.center)

                    if appState.currentLevel != .a1 {
                        Text(
                            "This A1 practice room is available when your lobby level is A1. "
                                + "Current: \(appState.currentLevel?.rawValue ?? "—")."
                        )
                            .font(Theme.Typography.rounded(.body, weight: .medium))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                    } else if let template = current {
                        VStack(alignment: .center, spacing: 14) {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.Colors.cardHighlight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
                                )
                                .frame(minHeight: 120)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Text(template.displayText)
                                            .font(Theme.Typography.rounded(.title3, weight: .medium))
                                            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                            .multilineTextAlignment(.center)
                                            .accessibilityIdentifier("grammarQuiz.prompt")
                                        Text("(\(template.englishHint))")
                                            .font(Theme.Typography.rounded(.caption, weight: .medium))
                                            .foregroundStyle(Theme.Colors.deepBrown)
                                            .multilineTextAlignment(.center)
                                        Text("Infinitive: \(template.infinitive)")
                                            .font(Theme.Typography.rounded(.caption, weight: .medium))
                                            .foregroundStyle(Theme.Colors.deepBrown)
                                    }
                                    .padding(16)
                                )

                            TextField(
                                "Conjugated verb",
                                text: $answer
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(Theme.Typography.rounded(.body, weight: .medium))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Theme.Colors.cardHighlight)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
                            )
                            .accessibilityIdentifier("grammarQuiz.answerField")

                            if let feedback {
                                Text(feedback)
                                    .font(Theme.Typography.rounded(.title3, weight: .medium))
                                    .foregroundStyle(
                                        isCorrect == true
                                            ? Theme.Colors.lobbyBoyPurple
                                            : Theme.Colors.lobbyBoyPurple.opacity(0.9)
                                    )
                                    .multilineTextAlignment(.center)
                            }

                            HStack(spacing: 10) {
                                Button("Check") {
                                    checkAnswer()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Colors.accentUI)

                                Button("Next") {
                                    advance()
                                }
                                .buttonStyle(.bordered)
                                .tint(Theme.Colors.accentSecondary)
                                .disabled(templates.isEmpty)
                            }
                        }
                    } else {
                        Text("No templates loaded.")
                            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    }
                }
                .padding(.vertical, 8)
                .vintageCard()
            }
        }
        .vintageScreenBackground()
        .navigationTitle("Tenses")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if templates.isEmpty {
                templates = A1GrammarSentenceLibrary.templates.shuffled()
            }
        }
    }

    private func checkAnswer() {
        guard let template = current else { return }
        let typed = GermanFlashcardAnswerNormalization.normalized(answer)
        let ok = template.acceptedAnswers.contains { GermanFlashcardAnswerNormalization.normalized($0) == typed }
        isCorrect = ok
        feedback = ok ? "Richtig!" : "Versuche es noch einmal."
    }

    private func advance() {
        guard !templates.isEmpty else { return }
        index = (index + 1) % templates.count
        answer = ""
        feedback = nil
        isCorrect = nil
    }
}

#Preview {
    NavigationStack {
        GrammarQuizView()
            .environmentObject(AppState())
    }
}
