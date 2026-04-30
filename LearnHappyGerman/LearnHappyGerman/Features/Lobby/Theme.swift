import SwiftUI

enum Theme {
    enum Colors {
        // Vintage hand-drawn illustrated map palette on warm beige paper.
        static let mendlsPink = Color(hex: "E7D8BE")      // Main paper background
        static let societyBlue = Color(hex: "6F8796")     // Route / frame accents
        static let lobbyBoyPurple = Color(hex: "4A3A2A")  // Sepia ink text / lines
        static let pastelYellow = Color(hex: "D7C39A")    // Highlight patches
        static let paperOverlay = Color(hex: "F4E9D4")    // Layered paper cards
    }

    enum Typography {
        /// Baseline rounded minimalist style.
        static func rounded(
            _ style: Font.TextStyle = .body,
            weight: Font.Weight = .medium
        ) -> Font {
            Font.system(style, design: .rounded, weight: weight)
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
