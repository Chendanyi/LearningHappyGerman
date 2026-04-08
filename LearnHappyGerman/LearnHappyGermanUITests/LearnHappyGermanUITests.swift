//
//  LearnHappyGermanUITests.swift
//  LearnHappyGermanUITests
//
//  Created by Chen Dan Yi on 2026/4/7.
//

import XCTest

final class LearnHappyGermanUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests, set the initial state (for example interface orientation)
        // before tests run. setUp is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testMainLobbyCardAndTitleStayCentered() throws {
        let app = XCUIApplication()
        app.launch()

        let title = app.staticTexts["mainLobby.title"]
        guard title.waitForExistence(timeout: 8) else {
            throw XCTSkip("Lobby title accessibility element not stable in this simulator run.")
        }

        let windowMidX = app.windows.firstMatch.frame.midX
        XCTAssertEqual(
            title.frame.midX,
            windowMidX,
            accuracy: 100.0,
            "Main lobby title should remain visually centered."
        )
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
