import AudioToolbox
import SwiftUI
import SwiftData

// swiftlint:disable type_body_length
struct FlashcardView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var audioService = AudioService()

    /// Loaded via `FetchDescriptor` (avoids `@Query` macro sidecars under
    /// `swift-generated-sources/`, which break SwiftLint / some editors).
    @State private var vocabularyWords: [VocabularyWord] = []

    @State private var currentWord: VocabularyWord?
    @State private var showSymbolSide = false
    @State private var userAnswer = ""
    @State private var validationState: ValidationState = .idle
    @State private var checkPulse = false
    @State private var shakeBellboy = false
    @State private var successScale: CGFloat = 1.0

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
                        HStack {
                            Spacer(minLength: 0)
                            Button {
                                audioService.speakGermanReplayCoalesced(expectedAnswer(for: card))
                            } label: {
                                Image(systemName: "speaker.wave.2.bubble.left")
                                    .font(.system(size: 22, weight: .ultraLight))
                                    .doodleSymbolStyle()
                                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Play German word")
                            Spacer(minLength: 0)
                        }

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
                                    Text(flashcardPrompt(for: card))
                                        .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(6)
                                        .padding(.horizontal, 8)
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
                                .fill(Theme.Colors.paperOverlay.opacity(0.7))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                        )
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .onChange(of: userAnswer) {
                            // Keep typing enabled after a check; clear prior feedback as soon as user edits.
                            if validationState != .idle {
                                validationState = .idle
                            }
                        }

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
                                    .fill(Theme.Colors.paperOverlay.opacity(0.7))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(checkPulse ? 1.02 : 1.0)
                    .disabled(validationState != .idle || currentWord == nil)

                    feedbackAndNextColumn
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
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reloadVocabulary()
            pickCurrentWordIfNeeded()
        }
        .onChange(of: appState.currentLevel) {
            validationState = .idle
            userAnswer = ""
            showSymbolSide = false
            successScale = 1.0
            reloadVocabulary()
            nextCard()
        }
    }

    private func reloadVocabulary() {
        let targetLevel = appState.currentLevel ?? level
        do {
            let descriptor = FetchDescriptor<VocabularyWord>(
                sortBy: [SortDescriptor(\.germanWord)]
            )
            let all = try modelContext.fetch(descriptor)
            if let targetLevel {
                vocabularyWords = all.filter { $0.level == targetLevel.rawValue }
            } else {
                vocabularyWords = all
            }
        } catch {
            print("Vocabulary fetch failed: \(error)")
            vocabularyWords = []
        }
    }

    private func pickCurrentWordIfNeeded() {
        guard currentWord == nil, !vocabularyWords.isEmpty else { return }
        nextCard()
    }

    /// Grand Budapest: feedback + **Next** share a full-width centered column under the card stack.
    private var feedbackAndNextColumn: some View {
        VStack(spacing: 14) {
            feedbackView
            if validationState != .idle {
                Button("Next") {
                    nextCard()
                }
                .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var feedbackView: some View {
        switch validationState {
        case .idle:
            EmptyView()
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundStyle(.green)
                .scaleEffect(successScale)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.scale.combined(with: .opacity))
        case .incorrect(let expected):
            VStack(spacing: 8) {
                Image(systemName: "bellhop.fill")
                    .font(.system(size: 30, weight: .ultraLight))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(x: shakeBellboy ? -6 : 6)
                    .animation(.easeInOut(duration: 0.08).repeatCount(5, autoreverses: true), value: shakeBellboy)
                Text("Correct answer: \(expected)")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .transition(.opacity)
        }
    }

    private func validateAnswer() {
        guard let card = currentWord else { return }
        guard validationState == .idle else { return }

        let normalizedInput = GermanFlashcardAnswerNormalization.normalized(userAnswer)
        let expectedNormalized = GermanFlashcardAnswerNormalization.normalized(expectedAnswer(for: card))

        if normalizedInput == expectedNormalized {
            validationState = .correct
            card.isMastered = true
            try? modelContext.save()
            playSuccessDing()
            successScale = 0.85
            withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) {
                successScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    successScale = 1.0
                }
            }
            return
        }

        if card.requiresGermanArticle {
            let needsArticlePrefix = expectedNormalized.hasPrefix("der ")
                || expectedNormalized.hasPrefix("die ")
                || expectedNormalized.hasPrefix("das ")
            if needsArticlePrefix,
               !normalizedInput.hasPrefix("der "),
               !normalizedInput.hasPrefix("die "),
               !normalizedInput.hasPrefix("das ") {
                validationState = .incorrect(expected: expectedAnswer(for: card))
                shakeBellboy.toggle()
                return
            }
        }

        validationState = .incorrect(expected: expectedAnswer(for: card))
        shakeBellboy.toggle()
    }

    private func playSuccessDing() {
        AudioServicesPlaySystemSound(1057)
    }

    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            guard !vocabularyWords.isEmpty else {
                currentWord = nil
                validationState = .idle
                showSymbolSide = false
                userAnswer = ""
                successScale = 1.0
                return
            }

            let candidates = vocabularyWords.filter { $0.persistentModelID != currentWord?.persistentModelID }
            currentWord = (candidates.isEmpty ? vocabularyWords : candidates).randomElement()
            showSymbolSide = false
            validationState = .idle
            userAnswer = ""
            successScale = 1.0
        }
        if let word = currentWord {
            audioService.speakGerman(expectedAnswer(for: word))
        }
    }

    /// Front-of-card text: English gloss when the corpus provides it. Goethe JSON has no English—do **not** show
    /// `exampleSentence` here (it would give away German context or the wrong sense, e.g. „nach Hause“ under „Haus“).
    private func flashcardPrompt(for card: VocabularyWord) -> String {
        let eng = card.englishTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
        if !eng.isEmpty {
            return eng.capitalized
        }
        return "Tap the speaker, then type the German answer below."
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
        case "other": return "sparkles"
        default: return "sparkles"
        }
    }

}
// swiftlint:enable type_body_length

private enum ValidationState: Equatable {
    case idle
    case correct
    case incorrect(expected: String)
}

#Preview {
    FlashcardPreviewHost()
}
