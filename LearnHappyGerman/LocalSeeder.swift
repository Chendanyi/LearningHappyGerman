import Foundation
import SwiftData

// MARK: - Bundle JSON shapes (stringly-typed for stable decoding)

private struct BundledDataPayload: Codable {
    let version: Int
    let words: [BundledWordDTO]
    let rules: [BundledRuleDTO]
}

private struct BundledWordDTO: Codable {
    let germanWord: String
    let article: String
    let englishTranslation: String
    let level: String
    let category: String
    let isMastered: Bool?
    let version: Int?
}

private struct BundledRuleDTO: Codable {
    let title: String
    let explanation: String
    let examples: String
    let ruleText: String
    let applicableLevelCode: String?
    let relatedGermanWord: String?
}

// MARK: - Local seeder

enum LocalSeederError: LocalizedError {
    case missingBundledFile
    case emptyVocabulary
    case invalidWord(String)
    case invalidRule(String)

    var errorDescription: String? {
        switch self {
        case .missingBundledFile:
            return "BundledData.json was not found in the app bundle."
        case .emptyVocabulary:
            return "BundledData.json contained no vocabulary words."
        case .invalidWord(let detail):
            return "Invalid word entry: \(detail)"
        case .invalidRule(let detail):
            return "Invalid rule entry: \(detail)"
        }
    }
}

/// Loads `BundledData.json` from the main bundle and inserts into SwiftData on first launch.
final class LocalSeeder {
    private let context: ModelContext

    static let bundledFileName = "BundledData"
    static let bundledFileExtension = "json"
    /// UserDefaults key: set after first successful bundled import (or legacy store skip).
    static let importCompletedDefaultsKey = "hasImportedBundledData.v1"

    init(context: ModelContext) {
        self.context = context
    }

    /// Imports bundled JSON. Call only when the store should receive the initial corpus (first launch path).
    func importFromBundle() throws -> (wordCount: Int, ruleCount: Int, bundleVersion: Int) {
        guard let url = Bundle.main.url(
            forResource: Self.bundledFileName,
            withExtension: Self.bundledFileExtension
        ) else {
            throw LocalSeederError.missingBundledFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(BundledDataPayload.self, from: data)

        guard !payload.words.isEmpty else {
            throw LocalSeederError.emptyVocabulary
        }

        var wordByHeadword: [String: VocabularyWord] = [:]

        for dto in payload.words {
            guard let article = GermanArticle(rawValue: dto.article) else {
                throw LocalSeederError.invalidWord("unknown article \(dto.article) for \(dto.germanWord)")
            }
            guard let level = CEFRLevel(rawValue: dto.level) else {
                throw LocalSeederError.invalidWord("unknown level \(dto.level) for \(dto.germanWord)")
            }
            guard let category = WordCategory(rawValue: dto.category) else {
                throw LocalSeederError.invalidWord("unknown category \(dto.category) for \(dto.germanWord)")
            }

            let word = VocabularyWord(
                germanWord: dto.germanWord,
                article: article,
                englishTranslation: dto.englishTranslation,
                level: level,
                category: category,
                isMastered: dto.isMastered ?? false,
                version: dto.version ?? 1
            )
            guard word.hasValidArticleForNoun else {
                throw LocalSeederError.invalidWord("noun \(dto.germanWord) must have der/die/das")
            }
            context.insert(word)
            wordByHeadword[dto.germanWord] = word
        }

        var ruleCount = 0
        for dto in payload.rules {
            let related: VocabularyWord?
            if let key = dto.relatedGermanWord {
                related = wordByHeadword[key]
                if related == nil {
                    throw LocalSeederError.invalidRule(
                        "relatedGermanWord \(key) not found for rule \(dto.title)"
                    )
                }
            } else {
                related = nil
            }

            var applicable: CEFRLevel?
            if let code = dto.applicableLevelCode {
                guard let lvl = CEFRLevel(rawValue: code) else {
                    throw LocalSeederError.invalidRule("bad applicableLevelCode \(code) for \(dto.title)")
                }
                applicable = lvl
            } else {
                applicable = nil
            }

            let rule = GrammarRule(
                title: dto.title,
                explanation: dto.explanation,
                examples: dto.examples,
                ruleText: dto.ruleText,
                applicableLevel: applicable,
                relatedWord: related
            )
            context.insert(rule)
            ruleCount += 1
        }

        try context.save()
        return (payload.words.count, ruleCount, payload.version)
    }
}

// MARK: - Observability (appendix for MEMORY.md)

enum IngestionAuditLogger {
    private static let appendixFileName = "MEMORY_ingestion_appendix.md"

    /// Writes a markdown block under Application Support for developers to paste into repo `MEMORY.md`.
    static func appendIngestionLog(wordCount: Int, ruleCount: Int, bundleVersion: Int) throws {
        let folder = try applicationSupportFolder()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent(appendixFileName, isDirectory: false)

        let isoFormatter = ISO8601DateFormatter()
        let stamp = isoFormatter.string(from: Date())
        let block = """

        ### [\(stamp)] Bundled data ingestion (runtime)

        - **Feature/Area:** Data ingestion (`LocalSeeder`, `BundledData.json`)
        - **Bundle payload version:** \(bundleVersion)
        - **Words imported:** \(wordCount)
        - **Rules imported:** \(ruleCount)
        - **Prevention Rule(s):** If counts are zero or import fails, do not ship; fix JSON and re-run.
        - **Note:** Copy this block into `MEMORY.md` Incident Log when integrating.

        ---
        """

        var existing = ""
        if FileManager.default.fileExists(atPath: url.path) {
            existing = try String(contentsOf: url, encoding: .utf8)
        }
        try (existing + block).write(to: url, atomically: true, encoding: .utf8)

        print("IngestionAudit: logged \(wordCount) words, \(ruleCount) rules → \(url.path)")
    }

    /// When a store already had vocabulary before bundled import was introduced.
    static func appendLegacyStoreLog(existingWordCount: Int) throws {
        let folder = try applicationSupportFolder()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent(appendixFileName, isDirectory: false)
        let isoFormatter = ISO8601DateFormatter()
        let stamp = isoFormatter.string(from: Date())
        let block = """

        ### [\(stamp)] Bundled import skipped (existing store)

        - **Existing vocabulary rows:** \(existingWordCount)
        - **Note:** Marked import complete without re-reading `BundledData.json`. Copy into `MEMORY.md` if relevant.

        ---
        """
        var existing = ""
        if FileManager.default.fileExists(atPath: url.path) {
            existing = try String(contentsOf: url, encoding: .utf8)
        }
        try (existing + block).write(to: url, atomically: true, encoding: .utf8)
    }

    private static func applicationSupportFolder() throws -> URL {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            struct AppSupportError: Error {}
            throw AppSupportError()
        }
        return base.appendingPathComponent("LearnHappyGerman", isDirectory: true)
    }
}
