import GoogleGenerativeAI

/// Builds `GenerativeModel` instances using the API key from `GoogleGenerativeAIConfiguration` (Info.plist).
enum GeminiGenerativeModelFactory {

    /// Default chat/creative model name; override when calling features need a different model.
    static var defaultModelName: String { GoogleGenerativeAIConfiguration.defaultGenerativeModelName }

    /// Creates a model with the bundled API key from Info.plist. Do not pass literals here.
    static func makeGenerativeModel(modelName: String = defaultModelName) throws -> GenerativeModel {
        guard let apiKey = APIConfig.googleAIAPIKey else {
            throw GoogleGenerativeAIConfigurationError.missingOrInvalidAPIKey
        }
        return GenerativeModel(name: modelName, apiKey: apiKey)
    }
}
