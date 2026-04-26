import Foundation
import SwiftData

// MARK: - Bundle JSON shapes

/// Goethe extractor output (`Data/scripts/extract_vocab.py`): top-level array.
private struct GermanVocabularyJSONRecord: Codable {
    let word: String
    let type: String
    let level: String
    let examples: [String]?
    let sourceFile: String?
    let article: String?
    let plural: String?
    let conjugation: String?
    let auxiliary: String?
    let perfect: String?
    /// Filled by `Data/scripts/extract_vocab.py --translate` (googletrans); optional for legacy JSON.
    let englishTranslation: String?

    enum CodingKeys: String, CodingKey {
        case word, type, level, examples, article, plural, conjugation, auxiliary, perfect, englishTranslation
        case sourceFile = "source_file"
    }
}

private struct GrammarRulesFilePayload: Codable {
    let version: Int
    let rules: [BundledRuleDTO]
}

private struct GrammarExampleDTO: Codable {
    let de: String
    let en: String
}

/// Bundled `grammar_rules.json` v3+ (`version` ≥ 3): structured fields + `examples` objects.
private struct BundledRuleDTO: Codable {
    let module: String?
    let title: String
    let level: String
    let germanTitle: String
    let formula: String
    let description: String
    let descriptionCN: String
    let examples: [GrammarExampleDTO]

    enum CodingKeys: String, CodingKey {
        case module, title, level, formula, description, examples
        case germanTitle = "german_title"
        case descriptionCN = "description_cn"
    }
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

private func normalizedPluralSuffix(_ raw: String?) -> String? {
    guard var suffix = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !suffix.isEmpty else { return nil }
    if let range = suffix.range(of: "  ") {
        suffix = String(suffix[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
    }
    if suffix.count > 32 {
        suffix = String(suffix.prefix(32))
    }
    return suffix.isEmpty ? nil : suffix
}

private func categoryFromJSONType(_ raw: String) -> String {
    let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard let first = lowered.first else { return "Other" }
    return String(first).uppercased() + lowered.dropFirst()
}

private func mergedExampleSentence(from record: GermanVocabularyJSONRecord) -> String? {
    var parts: [String] = []
    if let ex = record.examples {
        for line in ex where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    if let chunk = record.conjugation?.trimmingCharacters(in: .whitespacesAndNewlines), !chunk.isEmpty {
        parts.insert("Präsens: \(chunk)", at: 0)
    }
    if let aux = record.auxiliary?.trimmingCharacters(in: .whitespacesAndNewlines), !aux.isEmpty,
       let perf = record.perfect?.trimmingCharacters(in: .whitespacesAndNewlines), !perf.isEmpty {
        parts.insert("Perfekt: \(aux) \(perf)", at: 0)
    }
    guard !parts.isEmpty else { return nil }
    return parts.joined(separator: " ")
}

// MARK: - Local seeder

enum LocalSeederError: LocalizedError {
    case missingVocabularyFile
    case emptyVocabulary
    case invalidWord(String)
    case invalidRule(String)

    var errorDescription: String? {
        switch self {
        case .missingVocabularyFile:
            return "german_vocabulary.json was not found in the app bundle."
        case .emptyVocabulary:
            return "german_vocabulary.json contained no vocabulary words."
        case .invalidWord(let detail):
            return "Invalid word entry: \(detail)"
        case .invalidRule(let detail):
            return "Invalid grammar rule entry: \(detail)"
        }
    }
}

/// Counts returned by `LocalSeeder.mergeGermanVocabularyFromBundle()`.
struct GermanVocabularyMergeResult: Equatable {
    let inserted: Int
    let updated: Int
    let totalInFile: Int
}

/// Loads `german_vocabulary.json` (Goethe extractor output) and `grammar_rules.json` from the app bundle.
final class LocalSeeder {
    private let context: ModelContext

    static let germanVocabularyFileName = "german_vocabulary"
    static let germanVocabularyFileExtension = "json"
    static let grammarRulesFileName = "grammar_rules"
    static let grammarRulesFileExtension = "json"
    /// Set after first successful vocabulary merge (legacy key name kept for UserDefaults continuity).
    static let importCompletedDefaultsKey = "hasImportedBundledData.v1"

    init(context: ModelContext) {
        self.context = context
    }

    /// Idempotent merge: inserts missing `(germanWord, level)` rows from `german_vocabulary.json`, and fills
    /// `englishTranslation` on **existing** rows when the store value is empty but the bundle provides a gloss
    /// (so adding `englishTranslation` to JSON later still updates the UI without wiping SwiftData).
    func mergeGermanVocabularyFromBundle() throws -> GermanVocabularyMergeResult {
        guard let url = Bundle.main.url(
            forResource: Self.germanVocabularyFileName,
            withExtension: Self.germanVocabularyFileExtension
        ) else {
            throw LocalSeederError.missingVocabularyFile
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let records = try decoder.decode([GermanVocabularyJSONRecord].self, from: data)
        guard !records.isEmpty else {
            throw LocalSeederError.emptyVocabulary
        }

        let existing = try context.fetch(FetchDescriptor<VocabularyWord>())
        var existingByKey = Self.indexVocabularyWords(existing)

        var inserted = 0
        var updated = 0
        for record in records {
            let delta = try Self.processBundledRecord(
                record,
                context: context,
                existingByKey: &existingByKey
            )
            inserted += delta.inserted
            updated += delta.updated
            if delta.inserted > 0, inserted.isMultiple(of: 200) {
                try context.save()
            }
            if delta.updated > 0, updated.isMultiple(of: 200) {
                try context.save()
            }
        }

        if inserted > 0 || updated > 0 {
            try context.save()
        }
        return GermanVocabularyMergeResult(inserted: inserted, updated: updated, totalInFile: records.count)
    }

    private static func indexVocabularyWords(_ words: [VocabularyWord]) -> [String: VocabularyWord] {
        var map: [String: VocabularyWord] = [:]
        for word in words {
            let lemmaKey = word.germanWord.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = "\(lemmaKey)|\(word.level)"
            map[key] = word
        }
        return map
    }

    private struct BundledRecordDelta: Equatable {
        let inserted: Int
        let updated: Int
    }

    private static func processBundledRecord(
        _ record: GermanVocabularyJSONRecord,
        context: ModelContext,
        existingByKey: inout [String: VocabularyWord]
    ) throws -> BundledRecordDelta {
        let lemma = record.word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lemma.isEmpty, CEFRLevel.isValidLevelCode(record.level) else {
            return BundledRecordDelta(inserted: 0, updated: 0)
        }

        let key = "\(lemma)|\(record.level)"
        let english = record.englishTranslation?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let stored = existingByKey[key] {
            let current = stored.englishTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
            guard current.isEmpty, !english.isEmpty else {
                return BundledRecordDelta(inserted: 0, updated: 0)
            }
            stored.englishTranslation = english
            return BundledRecordDelta(inserted: 0, updated: 1)
        }

        let category = categoryFromJSONType(record.type)
        let exampleSentence = mergedExampleSentence(from: record)
        let articleString: String?
        let pluralSuffix: String?
        if category.lowercased() == "noun" {
            guard let artRaw = record.article else { return BundledRecordDelta(inserted: 0, updated: 0) }
            guard let parsed = try? parseBundledArticle(artRaw, germanWord: lemma) else {
                return BundledRecordDelta(inserted: 0, updated: 0)
            }
            articleString = parsed
            pluralSuffix = normalizedPluralSuffix(record.plural)
        } else {
            articleString = nil
            pluralSuffix = nil
        }

        let word = VocabularyWord(
            germanWord: lemma,
            article: articleString,
            englishTranslation: english,
            level: record.level,
            category: category,
            pluralSuffix: pluralSuffix,
            exampleSentence: exampleSentence,
            isMastered: false,
            version: 1
        )
        guard word.hasValidArticleForNoun else {
            return BundledRecordDelta(inserted: 0, updated: 0)
        }

        context.insert(word)
        existingByKey[key] = word
        return BundledRecordDelta(inserted: 1, updated: 0)
    }

    /// Inserts grammar rules from `grammar_rules.json` when their title is not already stored.
    func importGrammarRulesFromBundle() throws -> Int {
        guard let url = Bundle.main.url(
            forResource: Self.grammarRulesFileName,
            withExtension: Self.grammarRulesFileExtension
        ) else {
            return 0
        }

        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(GrammarRulesFilePayload.self, from: data)

        let existing = try context.fetch(FetchDescriptor<GrammarRule>())
        var titles = Set(existing.map(\.title))

        var inserted = 0
        for dto in payload.rules {
            guard CEFRLevel(rawValue: dto.level) != nil else {
                throw LocalSeederError.invalidRule("unknown level \(dto.level) for \(dto.title)")
            }
            guard !dto.examples.isEmpty else {
                throw LocalSeederError.invalidRule("examples empty for \(dto.title)")
            }
            let deLines = dto.examples.map(\.de).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let enLines = dto.examples.map(\.en).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard deLines.allSatisfy({ !$0.isEmpty }), enLines.allSatisfy({ !$0.isEmpty }) else {
                throw LocalSeederError.invalidRule("examples must have non-empty de/en for \(dto.title)")
            }
            guard !titles.contains(dto.title) else { continue }

            let rule = GrammarRule(
                module: dto.module?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                title: dto.title,
                germanTitle: dto.germanTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                formula: dto.formula.trimmingCharacters(in: .whitespacesAndNewlines),
                explanation: dto.description.trimmingCharacters(in: .whitespacesAndNewlines),
                descriptionCN: dto.descriptionCN.trimmingCharacters(in: .whitespacesAndNewlines),
                level: dto.level,
                exampleGermanLines: deLines,
                exampleEnglishLines: enLines
            )
            context.insert(rule)
            titles.insert(dto.title)
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

        - **Feature/Area:** Data ingestion (`LocalSeeder`, `german_vocabulary.json`, `grammar_rules.json`)
        - **Bundle payload version:** \(bundleVersion)
        - **Words in bundle file:** \(wordCount)
        - **Grammar rules imported (this run):** \(ruleCount)
        - **Prevention Rule(s):** If counts are zero or import fails, do not ship; fix JSON and re-run.
        - **Note:** Copy this block into `Documentation/MEMORY.md` Incident Log when integrating.

        ---
        """

        var existing = ""
        if FileManager.default.fileExists(atPath: url.path) {
            existing = try String(contentsOf: url, encoding: .utf8)
        }
        try (existing + block).write(to: url, atomically: true, encoding: .utf8)

        print("IngestionAudit: logged \(wordCount) bundle words, \(ruleCount) rules → \(url.path)")
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
        - **Note:** Marked import complete without re-reading bundle JSON. Copy into
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
