import SwiftUI

struct CityMapView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            mapContent
        }
        .toolbar(.hidden, for: .navigationBar)
        .vintageScreenBackground()
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                })
                .accessibilityLabel("Back")

                Spacer()

                Text("MY TOWN")
                    .font(.custom("PlayfairDisplay-Bold", size: 18))
                    .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                    .tracking(2)

                Spacer()

                Color.clear
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 4, trailing: 20))

            Text("Tap a building to start a location scene")
                .font(Theme.Typography.body(.caption, weight: .regular))
                .foregroundStyle(Theme.Colors.deepBrown)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 12, trailing: 24))
        }
    }

    private var mapContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("CityWalkMap")
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        Theme.Colors.pastelYellow.opacity(0.08)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .allowsHitTesting(false)
                    }
                    .overlay {
                        GeometryReader { proxy in
                            mapHotspots(
                                width: proxy.size.width,
                                height: proxy.size.height
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private func mapHotspots(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(Array(CityMapHotspotLayout.Building.allCases), id: \.self) { building in
                let center = building.normalizedCenter
                NavigationLink {
                    ScenarioDialogueView(building: building)
                        .environmentObject(appState)
                } label: {
                    hotspotTarget(for: building)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("citymap.hotspot.\(building.rawValue)")
                .position(x: width * center.x, y: height * center.y)
            }
        }
        .frame(width: width, height: height)
    }

    private func hotspotTarget(for building: CityMapHotspotLayout.Building) -> some View {
        let diameter: CGFloat = 88
        return Circle()
            .fill(Color.clear)
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .accessibilityLabel("Open \(building.rawValue)")
    }
}

#Preview {
    NavigationStack {
        CityMapView()
            .environmentObject(AppState())
    }
}
