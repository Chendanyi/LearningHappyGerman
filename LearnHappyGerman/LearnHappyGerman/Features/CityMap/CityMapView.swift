import SwiftUI

struct CityMapView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

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

                Button(action: {}, label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Theme.Colors.lobbyBoyPurple)
                })
                .accessibilityLabel("Settings")
                .accessibilityHint("Coming soon")
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
                    .padding(.horizontal, 16)
                    .overlay {
                        Theme.Colors.pastelYellow.opacity(0.08)
                            .allowsHitTesting(false)
                    }
                    .overlay(alignment: .topLeading) {
                        GeometryReader { proxy in
                            mapHotspots(
                                width: proxy.size.width,
                                height: proxy.size.height
                            )
                        }
                        .allowsHitTesting(true)
                    }
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private func mapHotspots(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
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
                    .stroke(Theme.Colors.accentPrimary.opacity(0.35), lineWidth: 1)
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
