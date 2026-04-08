import XCTest
@testable import LearnHappyGerman

final class GrammarQuizTests: XCTestCase {
    func testA1LibraryHasTemplates() {
        XCTAssertFalse(A1GrammarSentenceLibrary.templates.isEmpty)
    }

    func testIchGeheNachHauseAcceptsNormalizedAnswer() throws {
        let template = try XCTUnwrap(
            A1GrammarSentenceLibrary.templates.first { $0.displayText.contains("nach Hause") }
        )
        let normalized = GermanFlashcardAnswerNormalization.normalized("Gehe")
        XCTAssertTrue(
            template.acceptedAnswers.contains {
                GermanFlashcardAnswerNormalization.normalized($0) == normalized
            }
        )
    }
}
