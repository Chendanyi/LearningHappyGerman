import AVFoundation
import Foundation

/// German flashcard text-to-speech (de-DE) with a low-impact audio session and safe voice selection.
@MainActor
final class AudioService: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var replayCoalesceWorkItem: DispatchWorkItem?

    private static let germanLanguageCode = "de-DE"
    /// Short coalesce window so rapid speaker taps do not stack work before `stopSpeaking` runs.
    private static let manualReplayCoalesceSeconds: TimeInterval = 0.15

    init() {
        configureSessionForSpeech()
    }

    private func configureSessionForSpeech() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Mix with other apps; avoid grabbing exclusive playback from Music/podcasts.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            // Non-fatal: synthesizer may still use default routing.
        }
    }

    /// Speaks the given German text immediately, stopping any current utterance first.
    func speakGerman(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        replayCoalesceWorkItem?.cancel()
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = Self.preferredGermanVoice()
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 1.06
        synthesizer.speak(utterance)
    }

    /// Replays with a brief coalesce so rapid taps stay predictable and never queue overlapping jobs.
    func speakGermanReplayCoalesced(_ text: String) {
        replayCoalesceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.speakGerman(text)
        }
        replayCoalesceWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.manualReplayCoalesceSeconds, execute: work)
    }

    /// Picks a de-DE voice without force-unwrapping; falls back to default language voice or first match.
    private static func preferredGermanVoice() -> AVSpeechSynthesisVoice? {
        if let voice = AVSpeechSynthesisVoice(language: germanLanguageCode) {
            return voice
        }
        return AVSpeechSynthesisVoice.speechVoices().first { $0.language == germanLanguageCode }
    }
}
