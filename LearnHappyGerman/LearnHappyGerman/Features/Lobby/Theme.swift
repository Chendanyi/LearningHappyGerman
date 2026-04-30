import SwiftUI

enum Theme {
    enum Colors {
        // Warm paper + restrained vintage print palette.
        static let mendlsPink = Color(hex: "EADCC8")
        static let backgroundTop = Color(hex: "F3E8D6")
        static let backgroundBottom = Color(hex: "E2D2BA")
        static let societyBlue = Color(hex: "BFB6A8")       // System border / divider
        static let lobbyBoyPurple = Color(hex: "2F2A26")    // Primary text
        static let secondaryText = Color(hex: "4A443E")
        static let mutedText = Color(hex: "7A746B")
        static let pastelYellow = Color(hex: "D7C39A")
        static let paperOverlay = Color(hex: "F3E8D6")
        static let cardHighlight = Color(hex: "EFE2CD")
        static let accentPrimary = Color(hex: "C96A5A")
        static let accentSecondary = Color(hex: "D98C7A")
        static let mossGreen = Color(hex: "7A8F7A")
        static let sageGreen = Color(hex: "A3B18A")
        static let deepBrown = Color(hex: "8B6B4F")
        static let softBrown = Color(hex: "A1866F")
    }

    enum Typography {
        /// Serif-forward typography for a refined vintage print look.
        static func rounded(
            _ style: Font.TextStyle = .body,
            weight: Font.Weight = .medium
        ) -> Font {
            Font.system(style, design: .serif, weight: weight)
        }

        static func body(
            _ style: Font.TextStyle = .body,
            weight: Font.Weight = .regular
        ) -> Font {
            Font.system(style, design: .serif, weight: weight)
        }
    }

    enum Layout {
        /// Enforces centered, symmetric composition.
        static let maxContentWidth: CGFloat = 680
        static let horizontalPadding: CGFloat = 24
    }

    enum IconStyle {
        /// Thin-stroke icon baseline for doodle-like aesthetics.
        static let symbolWeight: Font.Weight = .ultraLight
        static let renderingMode: SymbolRenderingMode = .hierarchical
    }

    /// Grand Budapest Hotel “concierge board” symmetry for screens that render vocabulary from SwiftData.
    enum VocabularyGrandBudapest {
        @ViewBuilder
        static func symmetricContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            content().wesSymmetricLayout()
        }
    }
}

extension View {
    /// Applies the project symmetry rule: centered composition and constrained width.
    func wesSymmetricLayout() -> some View {
        self
            .frame(maxWidth: Theme.Layout.maxContentWidth, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, Theme.Layout.horizontalPadding)
    }

    /// Applies thin-stroke doodle icon styling.
    func doodleSymbolStyle() -> some View {
        self
            .fontWeight(Theme.IconStyle.symbolWeight)
            .symbolRenderingMode(Theme.IconStyle.renderingMode)
    }

    /// Global warm paper background with soft top-down gradient.
    func vintageScreenBackground() -> some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Colors.backgroundTop, Theme.Colors.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            self
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// Shared card style with thin border and subtle vintage depth.
    func vintageCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.Colors.paperOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.Colors.societyBlue, lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
    }
}

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: value).scanHexInt64(&int)

        let redChannel, greenChannel, blueChannel: Double
        switch value.count {
        case 3:
            redChannel = Double((int >> 8) * 17) / 255.0
            greenChannel = Double((int >> 4 & 0xF) * 17) / 255.0
            blueChannel = Double((int & 0xF) * 17) / 255.0
        case 6:
            redChannel = Double(int >> 16) / 255.0
            greenChannel = Double(int >> 8 & 0xFF) / 255.0
            blueChannel = Double(int & 0xFF) / 255.0
        default:
            redChannel = 1.0
            greenChannel = 1.0
            blueChannel = 1.0
        }

        self.init(.sRGB, red: redChannel, green: greenChannel, blue: blueChannel, opacity: 1.0)
    }
}
