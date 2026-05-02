import SwiftUI

/// Full-screen tiled paper texture from the `paper_texture` asset (no gradient or blend overlays).
struct VintagePaperBackground: View {
    var body: some View {
        Image("paper_texture")
            .resizable(resizingMode: .tile)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

#Preview {
    VintagePaperBackground()
}
