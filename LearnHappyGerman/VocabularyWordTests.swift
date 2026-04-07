import XCTest
@testable import LearnHappyGerman

final class VocabularyWordTests: XCTestCase {
    func testNounMustHaveValidArticle() {
        let nounWithoutArticle = VocabularyWord(
            germanWord: "Haus",
            article: nil,
            englishTranslation: "house",
            level: "A1",
            category: "Noun"
        )

        XCTAssertFalse(
            nounWithoutArticle.hasValidArticleForNoun,
            "Noun entries must include der/die/das."
        )

        let nounWithArticle = VocabularyWord(
            germanWord: "Mann",
            article: "der",
            englishTranslation: "man",
            level: "A1",
            category: "Noun"
        )

        XCTAssertTrue(nounWithArticle.hasValidArticleForNoun)
    }
}
