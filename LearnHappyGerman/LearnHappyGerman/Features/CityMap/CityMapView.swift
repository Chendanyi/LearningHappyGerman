import SwiftUI

struct CityMapView: View {
    @EnvironmentObject private var appState: AppState

    private enum CityBuilding: String, CaseIterable, Hashable {
        case trainStation = "Train Station"
        case bakery = "Bakery"
        case restaurant = "Restaurant"
        case coffeeShop = "Coffee Shop"
        case hospital = "Hospital"
        case centralHotel = "Central Hotel"
        case supermarket = "Supermarket"
        case shoppingCenter = "Shopping Center"
        case postOffice = "Post Office"
        case cinema = "Cinema"
        case school = "School"
        case townHall = "Town Hall"
    }

    var body: some View {
        ScrollView {
            Theme.VocabularyGrandBudapest.symmetricContent {
                VStack(spacing: 16) {
                    Text("CITYWALK")
                        .font(Theme.Typography.rounded(.largeTitle, weight: .medium))
                        .tracking(1.2)
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)

                    Text("Tap a building to start a location scene")
                        .font(Theme.Typography.body(.subheadline, weight: .regular))
                        .foregroundStyle(Theme.Colors.mutedText)

                    mapCanvas
                }
                .padding(24)
                .vintageCard()
            }
        }
        .vintageScreenBackground()
        .navigationTitle("CityWalk")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mapCanvas: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width * (1024.0 / 473.0)

            ZStack {
                Image("CityWalkMap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)

                hotspot(.trainStation, atX: 0.24, atY: 0.21, in: width, height: height)
                hotspot(.bakery, atX: 0.43, atY: 0.19, in: width, height: height)
                hotspot(.restaurant, atX: 0.73, atY: 0.18, in: width, height: height)
                hotspot(.coffeeShop, atX: 0.42, atY: 0.34, in: width, height: height)
                hotspot(.hospital, atX: 0.74, atY: 0.35, in: width, height: height)
                hotspot(.centralHotel, atX: 0.27, atY: 0.52, in: width, height: height)
                hotspot(.supermarket, atX: 0.69, atY: 0.52, in: width, height: height)
                hotspot(.shoppingCenter, atX: 0.27, atY: 0.68, in: width, height: height)
                hotspot(.postOffice, atX: 0.66, atY: 0.68, in: width, height: height)
                hotspot(.cinema, atX: 0.19, atY: 0.86, in: width, height: height)
                hotspot(.school, atX: 0.49, atY: 0.87, in: width, height: height)
                hotspot(.townHall, atX: 0.75, atY: 0.87, in: width, height: height)
            }
            .frame(width: width, height: height)
        }
        .aspectRatio(473.0 / 1024.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func hotspot(
        _ building: CityBuilding,
        atX normalizedX: CGFloat,
        atY normalizedY: CGFloat,
        in width: CGFloat,
        height: CGFloat
    ) -> some View {
        if building == .bakery {
            NavigationLink {
                SimpleLifeBakeryDialogueView()
                    .environmentObject(appState)
            } label: {
                hotspotTarget(for: building)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("citymap.hotspot.\(building.rawValue)")
            .position(x: width * normalizedX, y: height * normalizedY)
        } else {
            NavigationLink {
                CityLocationPlaceholderView(buildingName: building.rawValue)
            } label: {
                hotspotTarget(for: building)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("citymap.hotspot.\(building.rawValue)")
            .position(x: width * normalizedX, y: height * normalizedY)
        }
    }

    private func hotspotTarget(for building: CityBuilding) -> some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 72, height: 72)
            .overlay(
                Circle()
                    .stroke(Theme.Colors.accentPrimary.opacity(0.55), lineWidth: 1.2)
            )
            .contentShape(Circle())
            .accessibilityLabel("Open \(building.rawValue)")
    }
}

private struct CityLocationPlaceholderView: View {
    let buildingName: String

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text(buildingName.uppercased())
                    .font(Theme.Typography.rounded(.title2, weight: .medium))
                    .tracking(0.8)
                Text("Scene coming soon")
                    .font(Theme.Typography.body(.subheadline, weight: .regular))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .foregroundStyle(Theme.Colors.lobbyBoyPurple)
            .padding(24)
            .vintageCard(cornerRadius: 20)
            .wesSymmetricLayout()
        }
        .vintageScreenBackground()
        .navigationTitle(buildingName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CityMapView()
            .environmentObject(AppState())
    }
}
