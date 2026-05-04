import XCTest
@testable import LearnHappyGerman

@MainActor
final class CityScenarioEngineTests: XCTestCase {

    func testBakerySendsUserLineAndAppendsAIReply() async {
        let mock = MockCityScenarioAI(replies: ["Gern, hier sind Ihre Brötchen."])
        let config = ScenarioCatalog.config(for: .bakery)
        let engine = CityScenarioEngine(config: config, aiClient: mock)
        engine.startScenario()
        XCTAssertEqual(engine.conversationHistory.count, 1)

        await engine.submitUserLine("Drei Brötchen, bitte.")
        XCTAssertFalse(engine.isAwaitingAI)
        XCTAssertEqual(engine.conversationHistory.count, 3)
        XCTAssertEqual(engine.conversationHistory.last?.text, "Gern, hier sind Ihre Brötchen.")
        XCTAssertEqual(engine.turns.count, 3)
        XCTAssert(mock.invocations >= 1)
    }

    func testEmptyLineDoesNotAdvance() async {
        let mock = MockCityScenarioAI(replies: [])
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery), aiClient: mock)
        engine.startScenario()
        let before = engine.conversationHistory.count
        await engine.submitUserLine("   ")
        XCTAssertEqual(engine.conversationHistory.count, before)
        XCTAssertEqual(mock.invocations, 0)
    }

    func testAnyUserPhraseAcceptedWithAI() async {
        let mock = MockCityScenarioAI(replies: ["Verstanden."])
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery), aiClient: mock)
        engine.startScenario()
        await engine.submitUserLine("Ich hätte gern etwas Ungewöhnliches.")
        XCTAssertEqual(engine.conversationHistory.count, 3)
    }

    func testTrainStationAddsReply() async {
        let mock = MockCityScenarioAI(replies: ["Wohin möchten Sie fahren?"])
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .trainStation), aiClient: mock)
        engine.startScenario()
        await engine.submitUserLine("Nach Berlin, bitte.")
        XCTAssertGreaterThanOrEqual(engine.conversationHistory.count, 3)
        XCTAssertFalse(engine.isComplete)
    }

    func testSystemInstructionMentionsA1A2() async {
        let mock = MockCityScenarioAI(replies: ["OK"])
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery), aiClient: mock)
        engine.startScenario()
        await engine.submitUserLine("Hallo")
        XCTAssertTrue(mock.lastSystemInstruction?.contains("A1") == true)
        XCTAssertTrue(mock.lastSystemInstruction?.contains("A2") == true)
    }

    func testScenarioPhraseMatchingContainsLongerUtterance() {
        XCTAssertTrue(
            ScenarioPhraseMatching.matches(
                "Gern, ich möchte ein Ticket nach München, bitte.",
                acceptablePhrases: ["Nach München, bitte."]
            )
        )
    }

    func testScenarioPhraseMatchingRejectsUnrelated() {
        XCTAssertFalse(
            ScenarioPhraseMatching.matches(
                "Ich kaufe Schuhe.",
                acceptablePhrases: ["Nach München, bitte."]
            )
        )
    }
}

// MARK: - Test double

private final class MockCityScenarioAI: CityScenarioAIClient, @unchecked Sendable {
    private let replies: [String]
    private var index = 0
    private(set) var invocations = 0
    private(set) var lastSystemInstruction: String?

    init(replies: [String]) {
        self.replies = replies.isEmpty ? ["Standard-Antwort."] : replies
    }

    func generateAIResponse(prompt: String, systemInstruction: String) async throws -> String {
        invocations += 1
        lastSystemInstruction = systemInstruction
        defer { index += 1 }
        let replyIndex = min(index, replies.count - 1)
        return replies[max(0, replyIndex)]
    }
}
