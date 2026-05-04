import Foundation
import GoogleGenerativeAI

/// Wraps `GoogleGenerativeAI` with keys from `APIConfig` (Info.plist only).
struct GenerativeAIService {

    private static var modelName: String { GoogleGenerativeAIConfiguration.defaultGenerativeModelName }

    /// Generates a text reply using the given user prompt and system instruction.
    /// - Parameters:
    ///   - prompt: User-facing input.
    ///   - systemInstruction: High-level behavior / persona for this request.
    /// - Returns: Primary text from the first candidate, or empty string if none.
    func generateAIResponse(prompt: String, systemInstruction: String) async throws -> String {
        guard let apiKey = APIConfig.googleAIAPIKey else {
            throw GoogleGenerativeAIConfigurationError.missingOrInvalidAPIKey
        }
        let model = GenerativeModel(
            name: Self.modelName,
            apiKey: apiKey,
            systemInstruction: systemInstruction
        )
        let response = try await model.generateContent(prompt)
        return response.text ?? ""
    }
}
