import Foundation

/// Info.plist-backed API configuration (xcconfig → `GOOGLE_AI_API_KEY`).
/// See `GoogleGenerativeAIConfiguration` for keys and build wiring.
enum APIConfig {
    static var googleAIAPIKey: String? { GoogleGenerativeAIConfiguration.googleAIAPIKey }
}
