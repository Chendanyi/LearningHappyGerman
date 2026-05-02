import SwiftUI

final class AppState: ObservableObject {
    @Published var currentLevel: CEFRLevel?
    /// Set when bundled data import fails; shows a Human Takeover alert on the lobby.
    @Published var humanTakeoverMessage: String?
    /// `true` while first-run data bootstrap is importing on background actor.
    @Published var isInitializingVocabulary = false
    /// 0...1 progress for lobby loading indicator.
    @Published var initializationProgress: Double = 0
}

struct MainLobbyView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showHallway = false

    private let levels: [CEFRLevel] = [.a1, .a2, .b1, .b2, .c1, .c2]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .ultraLight))
                        .foregroundStyle(Theme.Colors.accentUI)
                        .doodleSymbolStyle()

                    Text("GRAND BUDAPEST DEUTSCH")
                        .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                        .tracking(1.2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .accessibilityIdentifier("mainLobby.title")

                    Text("SELECT YOUR CEFR LEVEL")
                        .font(Theme.Typography.rounded(.headline, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(Theme.Colors.secondaryText)

                    if appState.isInitializingVocabulary {
                        VStack(spacing: 8) {
                            Text("Preparing Vocabulary \(Int((appState.initializationProgress * 100).rounded()))%")
                                .font(Theme.Typography.body(.subheadline, weight: .regular))
                                .foregroundStyle(Theme.Colors.deepBrown)
                                .frame(maxWidth: .infinity, alignment: .center)
                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Theme.Colors.cardHighlight)
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Theme.Colors.accentUI)
                                        .frame(
                                            width: proxy.size.width
                                                * max(0, min(1, appState.initializationProgress))
                                        )
                                }
                            }
                            .frame(height: 10)
                            .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(levels, id: \.self) { level in
                            Button {
                                appState.currentLevel = level
                                withAnimation(.easeInOut(duration: 0.45)) {
                                    showHallway = true
                                }
                            } label: {
                                Text(level.rawValue)
                                    .font(Theme.Typography.rounded(.title3, weight: .semibold))
                                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Theme.Colors.cardHighlight)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(appState.isInitializingVocabulary)
                            .accessibilityIdentifier("mainLobby.level.\(level.rawValue)")
                        }
                    }
                }
                .padding(24)
                .vintageCard()
                .accessibilityIdentifier("mainLobby.card")
                .wesSymmetricLayout()
            }
            .vintageScreenBackground()
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showHallway) {
                ClassroomHallwayView()
            }
        }
        .alert("Human Takeover", isPresented: Binding(
            get: { appState.humanTakeoverMessage != nil },
            set: { if !$0 { appState.humanTakeoverMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                appState.humanTakeoverMessage = nil
            }
        } message: {
            Text(appState.humanTakeoverMessage ?? "Data import failed.")
        }
    }
}

struct ClassroomHallwayView: View {
    @EnvironmentObject private var appState: AppState

    private let classroomDoors: [ClassroomDoor] = [.flashcards, .tenses, .diceGame, .cityWalk, .hangman]

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                Text("CLASSROOM HALLWAY")
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .tracking(1.2)
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                Text("Current Level: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.body(.subheadline, weight: .regular))
                    .foregroundStyle(Theme.Colors.deepBrown)

                ForEach(classroomDoors, id: \.self) { door in
                    NavigationLink {
                        classroomDestination(for: door, level: appState.currentLevel)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "door.left.hand.open")
                                .font(.system(size: 16, weight: .ultraLight))
                                .doodleSymbolStyle()
                            Text(door.title)
                                .font(Theme.Typography.rounded(.headline, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .ultraLight))
                                .doodleSymbolStyle()
                        }
                        .padding(.horizontal, 16)
                    }
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.Colors.cardHighlight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
                    )
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hallway.door.\(door.rawValue)")
                }
            }
            .padding(24)
            .vintageCard()
            .wesSymmetricLayout()
        }
        .vintageScreenBackground()
        .navigationTitle("Hallway")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum ClassroomDoor: String, CaseIterable, Hashable {
    case flashcards = "Flashcards"
    case tenses = "Tenses"
    case diceGame = "Dice Game"
    case cityWalk = "CityWalk"
    case hangman = "Hangman"

    var title: String { rawValue }
}

@ViewBuilder
private func classroomDestination(for door: ClassroomDoor, level: CEFRLevel?) -> some View {
    switch door {
    case .flashcards:
        FlashcardView(level: level)
    case .tenses:
        GrammarQuizView()
    case .diceGame:
        ClassroomPlaceholderView(door: door)
    case .cityWalk:
        CityMapView()
    case .hangman:
        HangmanGameView()
    }
}

struct ClassroomPlaceholderView: View {
    @EnvironmentObject private var appState: AppState
    let door: ClassroomDoor

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text(door.title.uppercased())
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                Text("Coming soon")
                    .font(Theme.Typography.body(.title3, weight: .regular))
                    .foregroundStyle(Theme.Colors.secondaryText)
                Text("Level Scope: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.body(.subheadline, weight: .regular))
                    .foregroundStyle(Theme.Colors.deepBrown)
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 220)
            .vintageCard()
            .wesSymmetricLayout()
        }
        .vintageScreenBackground()
        .navigationTitle(door.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainLobbyView()
        .environmentObject(AppState())
}
