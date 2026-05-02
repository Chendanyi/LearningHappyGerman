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
                    // Hotspots must live in an overlay on the image so `GeometryReader` matches the
                    // actual drawn bitmap (a sibling `GeometryReader` in `ScrollView` often gets a
                    // taller frame than `scaledToFit`, which skews every normalized coordinate).
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

    /// Normalized centers (0…1, origin top-left) tuned to the current `CityWalkMap` illustration.
    private func mapHotspots(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            hotspot(.trainStation, atX: 0.30, atY: 0.10, in: width, height: height)
            hotspot(.bakery, atX: 0.53, atY: 0.15, in: width, height: height)
            hotspot(.restaurant, atX: 0.80, atY: 0.10, in: width, height: height)
            hotspot(.coffeeShop, atX: 0.40, atY: 0.32, in: width, height: height)
            hotspot(.hospital, atX: 0.78, atY: 0.35, in: width, height: height)
            hotspot(.centralHotel, atX: 0.30, atY: 0.53, in: width, height: height)
            hotspot(.supermarket, atX: 0.70, atY: 0.57, in: width, height: height)
            hotspot(.shoppingCenter, atX: 0.32, atY: 0.73, in: width, height: height)
            hotspot(.postOffice, atX: 0.70, atY: 0.74, in: width, height: height)
            hotspot(.cinema, atX: 0.23, atY: 0.90, in: width, height: height)
            hotspot(.school, atX: 0.50, atY: 0.90, in: width, height: height)
            hotspot(.townHall, atX: 0.78, atY: 0.90, in: width, height: height)
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
        let diameter: CGFloat = 88
        return Circle()
            .fill(Color.clear)
            .frame(width: diameter, height: diameter)
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
