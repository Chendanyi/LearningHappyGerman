import XCTest
@testable import LearnHappyGerman

final class VocabularyWordTests: XCTestCase {
    func testNounMustHaveValidArticle() {
        let nounWithoutArticle = VocabularyWord(
            germanWord: "Haus",
            article: .none,
            englishTranslation: "house",
            level: .a1,
            category: .noun
        )

        XCTAssertFalse(
            nounWithoutArticle.hasValidArticleForNoun,
            "Noun entries must include der/die/das."
        )

        let nounWithArticle = VocabularyWord(
            germanWord: "Mann",
            article: .der,
            englishTranslation: "man",
            level: .a1,
            category: .noun
        )

        XCTAssertTrue(nounWithArticle.hasValidArticleForNoun)
    }
}
