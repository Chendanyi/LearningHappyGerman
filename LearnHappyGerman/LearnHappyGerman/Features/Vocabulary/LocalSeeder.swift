import Foundation
import SwiftData

// MARK: - Bundle JSON shapes

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
    let level: String
    let exampleSentences: [String]
}

private struct InitialDataFilePayload: Codable {
    let version: Int
    let words: [InitialDataWordDTO]
}

private struct InitialDataWordDTO: Codable {
    let id: UUID
    let germanWord: String
    let article: String
    let englishTranslation: String
    let level: String
    let category: String
    let isMastered: Bool?
    let version: Int?
}

struct BundledImportResult {
    let wordCount: Int
    let ruleCount: Int
    let bundleVersion: Int
}

// MARK: - Article / level parsing

private func parseBundledArticle(_ raw: String, germanWord: String) throws -> String? {
    let trimmedArticle = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if trimmedArticle.isEmpty || trimmedArticle == "none" { return nil }
    guard trimmedArticle == "der" || trimmedArticle == "die" || trimmedArticle == "das" else {
        throw LocalSeederError.invalidWord("unknown article \(raw) for \(germanWord)")
    }
    return trimmedArticle
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
    static let initialDataFileName = "initial_data"
    static let initialDataFileExtension = "json"
    static let fullVocabularyFileName = "full_vocabulary"
    static let fullVocabularyFileExtension = "json"
    /// UserDefaults key: set after first successful bundled import (or legacy store skip).
    static let importCompletedDefaultsKey = "hasImportedBundledData.v1"

    init(context: ModelContext) {
        self.context = context
    }

    // swiftlint:disable function_body_length
    /// Imports bundled JSON. Call only when the store should receive the initial corpus (first launch path).
    func importFromBundle() throws -> BundledImportResult {
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

        for dto in payload.words {
            guard CEFRLevel(rawValue: dto.level) != nil else {
                throw LocalSeederError.invalidWord("unknown level \(dto.level) for \(dto.germanWord)")
            }

            let article = try parseBundledArticle(dto.article, germanWord: dto.germanWord)

            let word = VocabularyWord(
                germanWord: dto.germanWord,
                article: article,
                englishTranslation: dto.englishTranslation,
                level: dto.level,
                category: dto.category,
                pluralSuffix: nil,
                exampleSentence: nil,
                isMastered: dto.isMastered ?? false,
                version: dto.version ?? 1
            )
            guard word.hasValidArticleForNoun else {
                throw LocalSeederError.invalidWord("noun \(dto.germanWord) must have der/die/das")
            }
            context.insert(word)
        }

        var ruleCount = 0
        for dto in payload.rules {
            guard CEFRLevel(rawValue: dto.level) != nil else {
                throw LocalSeederError.invalidRule("unknown level \(dto.level) for \(dto.title)")
            }
            guard !dto.exampleSentences.isEmpty else {
                throw LocalSeederError.invalidRule("exampleSentences empty for \(dto.title)")
            }

            let rule = GrammarRule(
                title: dto.title,
                explanation: dto.explanation,
                level: dto.level,
                exampleSentences: dto.exampleSentences
            )
            context.insert(rule)
            ruleCount += 1
        }

        try context.save()
        return BundledImportResult(
            wordCount: payload.words.count,
            ruleCount: ruleCount,
            bundleVersion: payload.version
        )
    }
    // swiftlint:enable function_body_length

    /// Merges `initial_data.json` (30 A1 words, etc.).
    /// Inserts rows whose `(germanWord, level)` is not yet stored. Idempotent.
    func mergeInitialDataFromBundle() throws -> Int {
        guard let url = Bundle.main.url(
            forResource: Self.initialDataFileName,
            withExtension: Self.initialDataFileExtension
        ) else {
            return 0
        }

        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(InitialDataFilePayload.self, from: data)

        let existing = try context.fetch(FetchDescriptor<VocabularyWord>())
        var existingKeys = Set(existing.map { "\($0.germanWord)|\($0.level)" })

        var inserted = 0
        for dto in payload.words {
            let key = "\(dto.germanWord)|\(dto.level)"
            guard !existingKeys.contains(key) else { continue }

            let article = try parseBundledArticle(dto.article, germanWord: dto.germanWord)

            let word = VocabularyWord(
                id: dto.id,
                germanWord: dto.germanWord,
                article: article,
                englishTranslation: dto.englishTranslation,
                level: dto.level,
                category: dto.category,
                pluralSuffix: nil,
                exampleSentence: nil,
                isMastered: dto.isMastered ?? false,
                version: dto.version ?? 1
            )
            guard word.hasValidArticleForNoun else {
                throw LocalSeederError.invalidWord("initial_data: \(dto.germanWord) failed article/category validation")
            }
            context.insert(word)
            existingKeys.insert(key)
            inserted += 1
        }

        if inserted > 0 {
            try context.save()
        }
        return inserted
    }

    /// Merges `full_vocabulary.json` payload generated by `vocab_processor.py`.
    /// Inserts rows whose `(germanWord, level)` is not yet stored. Idempotent.
    func mergeFullVocabularyFromBundle() throws -> Int {
        guard let url = Bundle.main.url(
            forResource: Self.fullVocabularyFileName,
            withExtension: Self.fullVocabularyFileExtension
        ) else {
            return 0
        }

        let data = try Data(contentsOf: url)
        let records = try DataSeeder.decodeRecords(from: data)

        let existing = try context.fetch(FetchDescriptor<VocabularyWord>())
        var existingKeys = Set(existing.map { "\($0.germanWord)|\($0.level)" })

        var inserted = 0
        for record in records {
            let key = "\(record.germanWord)|\(record.level)"
            guard !existingKeys.contains(key) else { continue }
            guard CEFRLevel(rawValue: record.level) != nil else {
                throw LocalSeederError.invalidWord(
                    "full_vocabulary: unknown level \(record.level) for \(record.germanWord)"
                )
            }

            let article = try parseBundledArticle(record.article ?? "none", germanWord: record.germanWord)
            let word = VocabularyWord(
                germanWord: record.germanWord,
                article: article,
                englishTranslation: record.englishTranslation,
                level: record.level,
                category: record.category,
                pluralSuffix: record.pluralSuffix,
                exampleSentence: record.exampleSentence
            )
            guard word.hasValidArticleForNoun else {
                throw LocalSeederError.invalidWord(
                    "full_vocabulary: \(record.germanWord) failed article/category validation"
                )
            }
            context.insert(word)
            existingKeys.insert(key)
            inserted += 1
        }

        if inserted > 0 {
            try context.save()
        }
        return inserted
    }
}

// MARK: - Observability (appendix for Documentation/MEMORY.md)

enum IngestionAuditLogger {
    private static let appendixFileName = "MEMORY_ingestion_appendix.md"

    /// Writes a markdown block under Application Support for developers to paste into repo `Documentation/MEMORY.md`.
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
        - **Note:** Copy this block into `Documentation/MEMORY.md` Incident Log when integrating.

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
        - **Note:** Marked import complete without re-reading `BundledData.json`. Copy into
          `Documentation/MEMORY.md` if relevant.

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
