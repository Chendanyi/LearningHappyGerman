import SwiftUI
import SwiftData

struct HangmanGameLogic {
    static func isWin(word: String, guessedLetters: Set<Character>) -> Bool {
        word.allSatisfy { !($0.isLetter) || guessedLetters.contains($0) }
    }

    @discardableResult
    static func applyGuess(
        _ letter: Character,
        targetWord: String,
        guessedLetters: inout Set<Character>,
        remainingAttempts: inout Int
    ) -> Bool {
        guard !guessedLetters.contains(letter) else { return false }
        guessedLetters.insert(letter)
        if !targetWord.contains(letter) {
            remainingAttempts -= 1
        }
        return true
    }
}

struct HangmanGameView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var currentWord: VocabularyWord?
    @State private var targetWord = "KUCHEN"
    @State private var guessedLetters: Set<Character> = []
    @State private var remainingAttempts = 7

    private let maxAttempts = 7
    private let keyboardRows: [[Character]] = [
        Array("QWERTZUIOP"),
        Array("ASDFGHJKL"),
        Array("YXCVBNMÄÖÜß")
    ]

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink.ignoresSafeArea()

            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(spacing: 18) {
                    Image(systemName: "birthday.cake")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .doodleSymbolStyle()

                    Text("Hangman - Mendl's Cake Box")
                        .font(Theme.Typography.rounded(.title2, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .multilineTextAlignment(.center)

                    Text("Level: \(appState.currentLevel?.rawValue ?? "A1")")
                        .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.85))

                    if isWon {
                        conciergeCelebration
                    } else if isLost {
                        roomServiceLoss
                    } else {
                        cakeBoxDoodle
                    }

                    Text(revealedPrompt)
                        .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .tracking(4)
                        .multilineTextAlignment(.center)

                    Text(statusMessage)
                        .font(Theme.Typography.rounded(.headline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .multilineTextAlignment(.center)

                    keyboardGrid

                    Button("New Word") {
                        startNewRound()
                    }
                    .font(Theme.Typography.rounded(.headline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
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
        .navigationTitle("Hangman")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewRound()
        }
    }

    private var maskedWord: String {
        targetWord.map { letter in
            if guessedLetters.contains(letter) || !letter.isLetter {
                String(letter)
            } else {
                "_"
            }
        }
        .joined(separator: " ")
    }

    private var isNoun: Bool {
        currentWord?.category.lowercased() == "noun"
    }

    private var shownArticle: String {
        guard isNoun else { return "" }
        guard let article = currentWord?.article?.trimmingCharacters(in: .whitespacesAndNewlines),
              !article.isEmpty,
              article.lowercased() != "none"
        else {
            return ""
        }
        return article.lowercased()
    }

    private var revealedPrompt: String {
        if isNoun, !shownArticle.isEmpty {
            return "\(shownArticle) \(isLost ? targetWord : maskedWord)"
        }
        return isLost ? targetWord : maskedWord
    }

    private var isWon: Bool {
        HangmanGameLogic.isWin(word: targetWord, guessedLetters: guessedLetters)
    }

    private var isLost: Bool {
        remainingAttempts <= 0
    }

    private var statusMessage: String {
        if isWon {
            return "Wunderbar! The concierge celebrates your perfect German."
        }
        if isLost {
            return "Room Service cleared the broken cake box. Word: \(targetWord)"
        }
        return "Attempts left: \(remainingAttempts)"
    }

    private var conciergeCelebration: some View {
        Label("Concierge Congratulates You", systemImage: "person.crop.circle.badge.checkmark")
            .font(Theme.Typography.rounded(.headline, weight: .medium))
            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            .padding(.vertical, 10)
    }

    private var roomServiceLoss: some View {
        Label("Room Service Tray Arrived", systemImage: "takeoutbag.and.cup.and.straw")
            .font(Theme.Typography.rounded(.headline, weight: .medium))
            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            .padding(.vertical, 10)
    }

    private var cakeBoxDoodle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Colors.lobbyBoyPurple, lineWidth: 2)
                .frame(width: 240, height: 140)

            Rectangle()
                .fill(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 0) ? 0.95 : 0.18))
                .frame(width: 6, height: 138)

            Rectangle()
                .fill(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 1) ? 0.95 : 0.18))
                .frame(width: 236, height: 6)

            Circle()
                .stroke(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 2) ? 1 : 0.2), lineWidth: 2)
                .frame(width: 26, height: 26)
                .offset(x: -28, y: -50)

            Circle()
                .stroke(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 3) ? 1 : 0.2), lineWidth: 2)
                .frame(width: 26, height: 26)
                .offset(x: 28, y: -50)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 4) ? 1 : 0.2), lineWidth: 2)
                .frame(width: 56, height: 14)
                .offset(y: -50)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Theme.Colors.lobbyBoyPurple.opacity(decorationVisible(at: 5) ? 1 : 0.2), lineWidth: 2)
                .frame(width: 116, height: 16)
                .offset(y: 44)
        }
        .accessibilityIdentifier("hangman.cakeBox")
    }

    private var keyboardGrid: some View {
        VStack(spacing: 10) {
            ForEach(0 ..< keyboardRows.count, id: \.self) { rowIndex in
                let row = keyboardRows[rowIndex]
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { letter in
                        Button(String(letter)) {
                            handleGuess(letter)
                        }
                        .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .frame(width: 28, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Theme.Colors.societyBlue.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Theme.Colors.lobbyBoyPurple.opacity(0.7), lineWidth: 1)
                        )
                        .buttonStyle(.plain)
                        .disabled(isWon || isLost || guessedLetters.contains(letter))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func handleGuess(_ letter: Character) {
        guard !isWon, !isLost else { return }
        _ = HangmanGameLogic.applyGuess(
            letter,
            targetWord: targetWord,
            guessedLetters: &guessedLetters,
            remainingAttempts: &remainingAttempts
        )
    }

    private func decorationVisible(at index: Int) -> Bool {
        let consumedAttempts = maxAttempts - remainingAttempts
        return consumedAttempts <= index
    }

    private func startNewRound() {
        let levelCode = (appState.currentLevel ?? .a1).rawValue
        let descriptor = FetchDescriptor<VocabularyWord>(
            predicate: #Predicate { $0.level == levelCode }
        )

        let levelWords = (try? modelContext.fetch(descriptor)) ?? []
        if let selected = levelWords.randomElement() {
            currentWord = selected
            targetWord = selected.germanWord
                .uppercased()
                .replacingOccurrences(of: "ẞ", with: "SS")
        } else {
            currentWord = nil
            targetWord = "KUCHEN"
        }

        let level = appState.currentLevel ?? .a1
        if levelWords.isEmpty {
            targetWord = wordPool(for: level).randomElement() ?? "KUCHEN"
        }
        guessedLetters = []
        remainingAttempts = maxAttempts
    }

    private func wordPool(for level: CEFRLevel) -> [String] {
        switch level {
        case .a1: return ["APFEL", "BUCH", "TISCH", "HAUS", "TUER"]
        case .a2: return ["BAHNHOF", "FENSTER", "URLAUB", "KUECHE", "FAMILIE"]
        case .b1: return ["SPRACHE", "GEDANKE", "FREUNDSCHAFT", "BERUF", "HEIMAT"]
        case .b2: return ["RECHNUNG", "VERANTWORTUNG", "ENTWICKLUNG", "GESCHMACK"]
        case .c1: return ["WELTBILD", "HERAUSFORDERUNG", "AUFMERKSAMKEIT"]
        case .c2: return ["WELTANSCHAUUNG", "SELBSTVERSTANDNIS", "ZEITGEIST"]
        }
    }
}

#Preview {
    NavigationStack {
        HangmanGameView()
            .environmentObject(AppState())
    }
}
