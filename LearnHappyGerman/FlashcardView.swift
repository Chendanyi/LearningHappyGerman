import SwiftUI

struct FlashcardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentIndex = 0
    @State private var showSymbolSide = false
    @State private var userAnswer = ""
    @State private var validationState: ValidationState = .idle
    @State private var checkPulse = false
    @State private var shakeBellboy = false

    private let cards: [FlashcardItem] = [
        .init(englishWord: "apple", symbol: "apple.logo", germanWord: "Apfel", article: .der, category: .noun),
        .init(englishWord: "station", symbol: "tram", germanWord: "Bahnhof", article: .der, category: .noun),
        .init(englishWord: "to learn", symbol: "book.closed", germanWord: "lernen", article: .none, category: .verb)
    ]

    private var card: FlashcardItem {
        cards[currentIndex % cards.count]
    }

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink.ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Flashcards")
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                Text("Level: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.85))

                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSymbolSide.toggle()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Theme.Colors.societyBlue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Theme.Colors.lobbyBoyPurple, lineWidth: 6)
                            )

                        if showSymbolSide {
                            Image(systemName: card.symbol)
                                .font(.system(size: 60, weight: .ultraLight))
                                .doodleSymbolStyle()
                                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            Text(card.englishWord.capitalized)
                                .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                }
                .buttonStyle(.plain)

                TextField("Type German answer (e.g., der Apfel)", text: $userAnswer)
                    .font(Theme.Typography.rounded(.body, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.45))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                    )
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()

                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        checkPulse.toggle()
                    }
                    validateAnswer()
                } label: {
                    Text("Check")
                        .font(Theme.Typography.rounded(.headline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.45))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(checkPulse ? 1.02 : 1.0)

                feedbackView

                Button("Next Card") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex += 1
                        showSymbolSide = false
                        validationState = .idle
                        userAnswer = ""
                    }
                }
                .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.Colors.societyBlue.opacity(0.9), lineWidth: 2)
            )
            .wesSymmetricLayout()
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var feedbackView: some View {
        switch validationState {
        case .idle:
            EmptyView()
        case .correct:
            Image(systemName: "checkmark.circle")
                .font(.system(size: 26, weight: .ultraLight))
                .foregroundStyle(.green)
                .transition(.opacity)
        case .incorrect(let expected):
            VStack(spacing: 8) {
                Image(systemName: "bellhop.fill")
                    .font(.system(size: 30, weight: .ultraLight))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .offset(x: shakeBellboy ? -6 : 6)
                    .animation(.easeInOut(duration: 0.08).repeatCount(5, autoreverses: true), value: shakeBellboy)
                Text("Correct: \(expected)")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            }
            .transition(.opacity)
        }
    }

    private func validateAnswer() {
        let normalizedInput = normalized(userAnswer)
        let expected = normalized(card.expectedAnswer)

        if normalizedInput == expected {
            validationState = .correct
            return
        }

        // Noun constraint: article is mandatory.
        if card.category == .noun, !normalizedInput.hasPrefix("der "), !normalizedInput.hasPrefix("die "), !normalizedInput.hasPrefix("das ") {
            validationState = .incorrect(expected: card.expectedAnswer)
        } else {
            validationState = .incorrect(expected: card.expectedAnswer)
        }
        shakeBellboy.toggle()
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }
}

private struct FlashcardItem {
    let englishWord: String
    let symbol: String
    let germanWord: String
    let article: GermanArticle
    let category: WordCategory

    var expectedAnswer: String {
        category == .noun && article != .none ? "\(article.rawValue) \(germanWord)" : germanWord
    }
}

private enum ValidationState: Equatable {
    case idle
    case correct
    case incorrect(expected: String)
}

#Preview {
    NavigationStack {
        FlashcardView()
            .environmentObject(AppState())
    }
}
