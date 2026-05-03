import XCTest
@testable import LearnHappyGerman

final class CityMapHotspotLayoutTests: XCTestCase {
    func testAllBuildingsHaveTwelveHotspots() {
        XCTAssertEqual(CityMapHotspotLayout.Building.allCases.count, 12)
    }

    func testNormalizedCentersLieInUnitSquare() {
        for building in CityMapHotspotLayout.Building.allCases {
            let center = building.normalizedCenter
            XCTAssertGreaterThanOrEqual(center.x, 0, building.rawValue)
            XCTAssertLessThanOrEqual(center.x, 1, building.rawValue)
            XCTAssertGreaterThanOrEqual(center.y, 0, building.rawValue)
            XCTAssertLessThanOrEqual(center.y, 1, building.rawValue)
        }
    }
}
