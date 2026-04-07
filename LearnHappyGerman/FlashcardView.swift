import SwiftUI
import SwiftData

struct FlashcardView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @State private var vocabularyWords: [VocabularyWord] = []
    @State private var currentWord: VocabularyWord?
    @State private var showSymbolSide = false
    @State private var userAnswer = ""
    @State private var validationState: ValidationState = .idle
    @State private var checkPulse = false
    @State private var shakeBellboy = false
    @State private var hasAttemptedFallbackSeed = false

    let level: CEFRLevel?

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink.ignoresSafeArea()

            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(spacing: 18) {
                Text("Flashcards")
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                Text("Level: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.85))

                if let card = currentWord {
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
                                Image(systemName: symbol(for: card))
                                    .font(.system(size: 60, weight: .ultraLight))
                                    .doodleSymbolStyle()
                                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                    .transition(.opacity.combined(with: .scale))
                            } else {
                                Text(card.englishTranslation.capitalized)
                                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                    .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 260)
                    }
                    .buttonStyle(.plain)
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Theme.Colors.societyBlue.opacity(0.45))
                        .overlay(
                            Text("No vocabulary for selected level")
                                .font(Theme.Typography.rounded(.headline, weight: .medium))
                                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        )
                        .frame(maxWidth: .infinity, minHeight: 260)
                }

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
                    nextCard()
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
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reloadVocabulary()
            ensureVocabularyAvailability()
            if currentWord == nil {
                nextCard()
            }
        }
        .onChange(of: appState.currentLevel) {
            reloadVocabulary()
            ensureVocabularyAvailability()
            nextCard()
        }
    }

    private func ensureVocabularyAvailability() {
        guard !hasAttemptedFallbackSeed, vocabularyWords.isEmpty else { return }
        hasAttemptedFallbackSeed = true
        let seeder = DataSeeder(context: modelContext)
        do {
            try seeder.seedIfNeeded(records: DataSeeder.starterVocabulary)
        } catch {
            print("Flashcard fallback seed failed: \(error)")
        }
        reloadVocabulary()
    }

    private func reloadVocabulary() {
        let targetLevel = appState.currentLevel ?? level
        do {
            let allWords = try modelContext.fetch(FetchDescriptor<VocabularyWord>())
            if let targetLevel {
                vocabularyWords = allWords.filter { $0.level == targetLevel.rawValue }
            } else {
                vocabularyWords = allWords
            }
        } catch {
            print("Vocabulary fetch failed: \(error)")
            vocabularyWords = []
        }
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
        guard let card = currentWord else { return }
        let normalizedInput = normalized(userAnswer)
        let expected = normalized(expectedAnswer(for: card))

        if normalizedInput == expected {
            validationState = .correct
            return
        }

        // When the expected answer includes an article, require der/die/das in the user input.
        let expectedNeedsArticle = expected.hasPrefix("der ")
            || expected.hasPrefix("die ")
            || expected.hasPrefix("das ")
        if expectedNeedsArticle,
           !normalizedInput.hasPrefix("der "),
           !normalizedInput.hasPrefix("die "),
           !normalizedInput.hasPrefix("das ") {
            validationState = .incorrect(expected: expectedAnswer(for: card))
        } else {
            validationState = .incorrect(expected: expectedAnswer(for: card))
        }
        shakeBellboy.toggle()
    }

    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            guard !vocabularyWords.isEmpty else {
                currentWord = nil
                validationState = .idle
                showSymbolSide = false
                userAnswer = ""
                return
            }

            let candidates = vocabularyWords.filter { $0.persistentModelID != currentWord?.persistentModelID }
            currentWord = (candidates.isEmpty ? vocabularyWords : candidates).randomElement()
            showSymbolSide = false
            validationState = .idle
            userAnswer = ""
        }
    }

    private func expectedAnswer(for word: VocabularyWord) -> String {
        guard let art = word.article?.trimmingCharacters(in: .whitespacesAndNewlines),
              !art.isEmpty,
              art.lowercased() != "none" else {
            return word.germanWord
        }
        let lower = art.lowercased()
        guard lower == "der" || lower == "die" || lower == "das" else {
            return word.germanWord
        }
        return "\(art) \(word.germanWord)"
    }

    private func symbol(for word: VocabularyWord) -> String {
        switch word.category.lowercased() {
        case "noun",
             "daily life",
             "activities",
             "travel",
             "home",
             "people",
             "time":
            return "tag"
        case "verb": return "figure.walk"
        case "adjective": return "paintpalette"
        case "adverb": return "speedometer"
        case "phrase": return "text.quote"
        case "expression": return "ellipsis.bubble"
        default: return "sparkles"
        }
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }
}

private enum ValidationState: Equatable {
    case idle
    case correct
    case incorrect(expected: String)
}

#Preview {
    NavigationStack {
        FlashcardView(level: .a1)
            .environmentObject(AppState())
    }
}
