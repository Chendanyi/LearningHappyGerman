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
                Theme.Colors.mendlsPink
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .ultraLight))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                        .doodleSymbolStyle()

                    Text("Grand Budapest Deutsch")
                        .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                    Text("Select Your CEFR Level")
                        .font(Theme.Typography.rounded(.headline, weight: .medium))
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.9))

                    if appState.isInitializingVocabulary {
                        VStack(spacing: 8) {
                            Text("Preparing Vocabulary \(Int((appState.initializationProgress * 100).rounded()))%")
                                .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                                .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.88))
                                .frame(maxWidth: .infinity, alignment: .center)
                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.white.opacity(0.45))
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Theme.Colors.societyBlue)
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
                                    .font(Theme.Typography.rounded(.title3, weight: .medium))
                                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.white.opacity(0.42))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(appState.isInitializingVocabulary)
                        }
                    }
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

    private let classroomDoors: [ClassroomDoor] = [.flashcards, .tenses, .diceGame, .aiDialogue, .hangman]

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Classroom Hallway")
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                Text("Current Level: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.85))

                ForEach(classroomDoors, id: \.self) { door in
                    NavigationLink {
                        classroomDestination(for: door, level: appState.currentLevel)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "door.left.hand.open")
                                .font(.system(size: 16, weight: .ultraLight))
                                .doodleSymbolStyle()
                            Text(door.title)
                                .font(Theme.Typography.rounded(.headline, weight: .medium))
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
                            .fill(Color.white.opacity(0.42))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.Colors.societyBlue, lineWidth: 2)
                    )
                    .buttonStyle(.plain)
                }
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
        .navigationTitle("Hallway")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum ClassroomDoor: String, CaseIterable, Hashable {
    case flashcards = "Flashcards"
    case tenses = "Tenses"
    case diceGame = "Dice Game"
    case aiDialogue = "AI Dialogue"
    case hangman = "Hangman"

    var title: String { rawValue }
}

@ViewBuilder
private func classroomDestination(for door: ClassroomDoor, level: CEFRLevel?) -> some View {
    switch door {
    case .flashcards:
        FlashcardView(level: level)
    default:
        ClassroomPlaceholderView(door: door)
    }
}

struct ClassroomPlaceholderView: View {
    @EnvironmentObject private var appState: AppState
    let door: ClassroomDoor

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text(door.title)
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                Text("Coming soon")
                    .font(Theme.Typography.rounded(.title3, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.9))
                Text("Level Scope: \(appState.currentLevel?.rawValue ?? "Not Selected")")
                    .font(Theme.Typography.rounded(.subheadline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.8))
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.Colors.societyBlue, lineWidth: 2)
            )
            .wesSymmetricLayout()
        }
        .navigationTitle(door.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainLobbyView()
        .environmentObject(AppState())
}
