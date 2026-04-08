import XCTest
@testable import LearnHappyGerman

/// Evaluator: Audio Concierge uses AVFoundation without force-unwrapping on voice selection.
@MainActor
final class AudioServiceTests: XCTestCase {
    func testSpeakGermanEmptyStringDoesNotCrash() {
        let audio = AudioService()
        audio.speakGerman("")
    }

    func testSpeakGermanSamplePhraseDoesNotCrash() {
        let audio = AudioService()
        audio.speakGerman("der Apfel")
        audio.speakGermanReplayCoalesced("gehen")
    }
}
