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

    func testNounArticleRuleHoldsForEveryCEFRLevel() {
        for level in CEFRLevel.allCases {
            let nounWithoutArticle = VocabularyWord(
                germanWord: "TestWord\(level.rawValue)",
                article: nil,
                englishTranslation: "test",
                level: level.rawValue,
                category: "Noun"
            )
            XCTAssertFalse(
                nounWithoutArticle.hasValidArticleForNoun,
                "Noun + Article rule must hold for level \(level.rawValue)."
            )

            let nounWithArticle = VocabularyWord(
                germanWord: "ValidWord\(level.rawValue)",
                article: "der",
                englishTranslation: "valid",
                level: level.rawValue,
                category: "Noun"
            )
            XCTAssertTrue(
                nounWithArticle.hasValidArticleForNoun,
                "Noun with article should pass for level \(level.rawValue)."
            )
        }
    }
}
