import Foundation

/// Abstraction for Gemini calls so `CityScenarioEngine` stays testable without a real API key.
protocol CityScenarioAIClient: Sendable {
    func generateAIResponse(prompt: String, systemInstruction: String) async throws -> String
}

/// Production client using `GenerativeAIService` and Info.plist API key (via `APIConfig`).
struct LiveGenerativeAIClient: CityScenarioAIClient {
    private let service: GenerativeAIService

    init(service: GenerativeAIService = GenerativeAIService()) {
        self.service = service
    }

    func generateAIResponse(prompt: String, systemInstruction: String) async throws -> String {
        try await service.generateAIResponse(prompt: prompt, systemInstruction: systemInstruction)
    }
}
