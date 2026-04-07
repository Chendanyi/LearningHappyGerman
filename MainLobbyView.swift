import SwiftUI

struct MainLobbyView: View {
    @Binding var selectedLevel: CEFRLevel?
    var onEnterHallway: ((CEFRLevel) -> Void)?

    private let levels: [CEFRLevel] = [.a1, .a2, .b1, .b2, .c1, .c2]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        ZStack {
            Theme.Colors.mendlsPink
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "bell")
                    .font(.system(size: 17, weight: .ultraLight))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .doodleSymbolStyle()
                    .padding(.top, 8)

                Text("Grand Budapest Deutsch")
                    .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                Text("Select Your CEFR Level")
                    .font(Theme.Typography.rounded(.headline, weight: .medium))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple.opacity(0.9))
                    .padding(.bottom, 6)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(levels, id: \.self) { level in
                        Button {
                            selectedLevel = level
                            onEnterHallway?(level)
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
    }
}

#Preview {
    MainLobbyView(selectedLevel: .constant(nil))
}
