import SwiftUI

enum Theme {
    enum Colors {
        // Rejuvenated parchment palette — see project README / AGENTS for roles.
        /// Primary ink / high-contrast text.
        static let lobbyBoyPurple = Color(hex: "2F2A26")
        /// Body text / secondary labels.
        static let secondaryText = Color(hex: "4A443E")
        /// Tertiary text / hints (replaces former muted gray in UI).
        static let deepBrown = Color(hex: "8B6B4F")
        /// Map-only highlights: hotspots, map markers (not general buttons).
        static let accentPrimary = Color(hex: "C96A5A")
        /// General UI buttons and interactive accents.
        static let accentUI = Color(hex: "B05A4A")
        /// Map road wash / warm map accent; optional card highlights.
        static let pastelYellow = Color(hex: "D7C39A")
        /// Warm accent / subtle outlines (optional; not used on `vintageCard` border).
        static let softBrown = Color(hex: "A1866F")
        /// Success / correct answers.
        static let mossGreen = Color(hex: "7A8F7A")
        /// Primary card / panel fill (`vintageCard` uses at 0.9 opacity so `paper_texture` shows through).
        static let cardFill = Color(hex: "EDD9B4")
        /// Standard UI borders (non-card dividers, controls).
        static let societyBlue = Color(hex: "BFB6A8")
        /// Inset surfaces: text fields, selected panels, inner chrome.
        static let cardHighlight = Color(hex: "F7F0E3")
        /// Secondary accent (e.g. alternate toggle emphasis).
        static let accentSecondary = Color(hex: "D98C7A")
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

    /// Global tiled parchment background (`paper_texture`) behind main navigation content.
    func vintageScreenBackground() -> some View {
        ZStack {
            VintagePaperBackground()
            self
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// Shared card: translucent warm fill, organic deep-brown frame, warm shadow.
    func vintageCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.Colors.cardFill.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.Colors.deepBrown, lineWidth: 1.2)
            )
            .shadow(color: Color(hex: "5C4B37").opacity(0.15), radius: 4, x: 0, y: 2)
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
