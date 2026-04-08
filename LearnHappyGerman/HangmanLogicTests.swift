import XCTest
@testable import LearnHappyGerman

final class HangmanLogicTests: XCTestCase {
    func testHangmanWinWhenAllLettersGuessed() {
        let guessed: Set<Character> = ["H", "A", "U", "S"]
        XCTAssertTrue(HangmanGameLogic.isWin(word: "HAUS", guessedLetters: guessed))
    }

    func testHangmanDuplicateGuessDoesNotConsumeAttempt() {
        var guessed: Set<Character> = []
        var remainingAttempts = 7

        let firstGuessAccepted = HangmanGameLogic.applyGuess(
            "Z",
            targetWord: "HAUS",
            guessedLetters: &guessed,
            remainingAttempts: &remainingAttempts
        )
        XCTAssertTrue(firstGuessAccepted)
        XCTAssertEqual(remainingAttempts, 6)

        let secondGuessAccepted = HangmanGameLogic.applyGuess(
            "Z",
            targetWord: "HAUS",
            guessedLetters: &guessed,
            remainingAttempts: &remainingAttempts
        )
        XCTAssertFalse(secondGuessAccepted)
        XCTAssertEqual(remainingAttempts, 6)
    }
}
