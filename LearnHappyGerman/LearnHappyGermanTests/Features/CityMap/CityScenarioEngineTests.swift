import XCTest
@testable import LearnHappyGerman

@MainActor
final class CityScenarioEngineTests: XCTestCase {
    func testBakeryScenarioCompletesFullDialogue() {
        let config = ScenarioCatalog.config(for: .bakery)
        let engine = CityScenarioEngine(config: config)
        engine.startScenario()
        XCTAssertEqual(engine.turns.count, 1)

        engine.submitUserLine("Drei Brötchen, bitte.")
        XCTAssertGreaterThanOrEqual(engine.turns.count, 3)

        engine.submitUserLine("Nein, danke. Das ist alles.")
        XCTAssertTrue(engine.isComplete)
        XCTAssertEqual(engine.turns.count, 5)
    }

    func testEmptyLineDoesNotAdvance() {
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery))
        engine.startScenario()
        let before = engine.turns.count
        engine.submitUserLine("   ")
        XCTAssertEqual(engine.turns.count, before)
    }

    func testWrongPhraseDoesNotAdvance() {
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery))
        engine.startScenario()
        let before = engine.turns.count
        engine.submitUserLine("Ich kaufe ein Auto.")
        XCTAssertEqual(engine.turns.count, before)
    }

    func testSecondValidOrderIgnoredAfterFirstRound() {
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .bakery))
        engine.startScenario()
        engine.submitUserLine("Drei Brötchen, bitte.")
        let countAfterFirst = engine.turns.count
        engine.submitUserLine("Drei Brötchen, bitte.")
        XCTAssertEqual(engine.turns.count, countAfterFirst)
    }

    func testTrainStationFirstRound() {
        let engine = CityScenarioEngine(config: ScenarioCatalog.config(for: .trainStation))
        engine.startScenario()
        engine.submitUserLine("Nach München, bitte.")
        XCTAssertEqual(engine.turns.count, 3)
        XCTAssertFalse(engine.isComplete)
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
