import XCTest
@testable import LearnHappyGerman

@MainActor
final class BakeryScenarioTests: XCTestCase {
    func testBakeryScenarioCompletesFourPlusExchanges() {
        let engine = BakeryScenarioEngine()
        engine.startScenario()
        XCTAssertEqual(engine.turns.count, 1)

        engine.submitOrder("Zwei Brötchen, bitte.")
        XCTAssertGreaterThanOrEqual(engine.turns.count, 3)

        engine.submitExtraAnswer("Nein, danke.")
        XCTAssertGreaterThanOrEqual(engine.turns.count, 5)

        engine.submitPriceQuestion("Was kostet das?")
        XCTAssertEqual(engine.phase, .done)
        XCTAssertGreaterThanOrEqual(engine.turns.count, 7)
    }
}
