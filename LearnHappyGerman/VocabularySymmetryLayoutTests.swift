import XCTest
import SwiftUI
@testable import LearnHappyGerman

/// Evaluator: vocabulary screens must use the Grand Budapest symmetric column (`wesSymmetricLayout` contract).
final class VocabularySymmetryLayoutTests: XCTestCase {
    func testGrandBudapestThemeTokensMatchSymmetricLayoutContract() {
        XCTAssertEqual(Theme.Layout.horizontalPadding, 24)
        XCTAssertEqual(Theme.Layout.maxContentWidth, 680)
    }

    func testVocabularyGrandBudapestWrapperBuilds() {
        _ = Theme.VocabularyGrandBudapest.symmetricContent {
            Color.clear
        }
    }
}
