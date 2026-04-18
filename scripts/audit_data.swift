#!/usr/bin/env swift
// Standalone data audit for `full_vocabulary.json` (matches `DataSeeder.decodeRecords` payload shape).
// Run: swift scripts/audit_data.swift [optional/path/to/full_vocabulary.json]
//
// Rules: rows with category "Noun" (case-insensitive) must have der/die/das; `germanWord` must use
// Latin-script characters acceptable for German lemmas (umlauts, ß, hyphen, apostrophe, spaces).
// Thematic categories (e.g. Travel, Food) are not treated as grammatical "Noun" here—use category "Noun" for noun lemmas.
import Foundation

// MARK: - Payload (aligned with DataSeeder)

struct VocabularySeedPayload: Codable {
    let version: Int
    let words: [VocabularySeedRecord]
}

struct VocabularySeedRecord: Codable {
    let id: UUID?
    let germanWord: String
    let article: String?
    let englishTranslation: String
    let level: String
    let category: String
    let version: Int?
    let pluralSuffix: String?
    let exampleSentence: String?
}

// MARK: - Rules

private let validLevels: Set<String> = ["A1", "A2", "B1", "B2", "C1", "C2"]

private func normalizedArticle(_ article: String?) -> String? {
    guard let article else { return nil }
    let trimmed = article.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty || trimmed.lowercased() == "none" { return nil }
    return trimmed.lowercased()
}

/// Strict audit: only rows with `category` literally "Noun" must carry der/die/das (matches learner expectation for noun lemmas).
private func nounRowMissingArticle(category: String, article: String?) -> Bool {
    guard category.lowercased() == "noun" else { return false }
    guard let art = normalizedArticle(article) else { return true }
    return !(art == "der" || art == "die" || art == "das")
}

/// Flags characters outside Latin-script letters used for German lemmas, plus space, hyphen, apostrophe, hyphen variants.
private func invalidGermanLemmaReason(for word: String) -> String? {
    for scalar in word.unicodeScalars {
        let v = scalar.value
        if CharacterSet.whitespaces.contains(scalar) {
            continue
        }
        // Hyphen, apostrophe, ASCII hyphen-minus
        if v == 0x002D || v == 0x2010 || v == 0x2011 || v == 0x0027 || v == 0x2019 || v == 0x00B7 {
            continue
        }
        // Latin-1 / Latin Extended-A / Latin Extended-B / Latin Extended Additional (common for German)
        if (0x0041...0x005A).contains(v) || (0x0061...0x007A).contains(v) {
            continue
        }
        if (0x00C0...0x024F).contains(v) {
            continue
        }
        if (0x1E00...0x1EFF).contains(v) {
            continue
        }
        // ß / ẞ
        if v == 0x00DF || v == 0x1E9E {
            continue
        }
        // Digits (e.g. "3D") — not valid in lemma field for this corpus
        if (0x0030...0x0039).contains(v) {
            return "unexpected digit U+\(String(v, radix: 16, uppercase: true))"
        }
        return "invalid character U+\(String(v, radix: 16, uppercase: true)) in \(word.debugDescription)"
    }
    return nil
}

private func decodeRecords(from data: Data) throws -> [VocabularySeedRecord] {
    let decoder = JSONDecoder()
    if let wrapped = try? decoder.decode(VocabularySeedPayload.self, from: data) {
        return wrapped.words
    }
    return try decoder.decode([VocabularySeedRecord].self, from: data)
}

private func resolveDefaultVocabularyURLs() -> [URL] {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    let candidates = [
        cwd.appendingPathComponent("LearnHappyGerman/LearnHappyGerman/full_vocabulary.json"),
        cwd.appendingPathComponent("LearnHappyGerman/full_vocabulary.json")
    ]
    var seen = Set<String>()
    var result: [URL] = []
    for url in candidates where FileManager.default.fileExists(atPath: url.path) {
        let key = url.resolvingSymlinksInPath().standardizedFileURL.path
        if seen.insert(key).inserted {
            result.append(url)
        }
    }
    return result
}

// MARK: - Main

var args = CommandLine.arguments.dropFirst()
let pathArg: String? = args.first

let urlsToAudit: [URL]
if let pathArg {
    let single: URL
    if pathArg.hasPrefix("/") {
        single = URL(fileURLWithPath: pathArg)
    } else {
        single = URL(fileURLWithPath: pathArg, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
            .standardizedFileURL
    }
    urlsToAudit = [single]
} else {
    urlsToAudit = resolveDefaultVocabularyURLs()
}

if urlsToAudit.isEmpty {
    fputs(
        "audit_data: no full_vocabulary.json found (skipped). Expected at LearnHappyGerman/LearnHappyGerman/full_vocabulary.json or LearnHappyGerman/full_vocabulary.json\n",
        stderr
    )
    exit(0)
}

var allErrors: [String] = []
var totalRows = 0
for url in urlsToAudit {
    guard FileManager.default.fileExists(atPath: url.path) else {
        allErrors.append("missing file \(url.path)")
        continue
    }
    let data = try Data(contentsOf: url)
    let records = try decodeRecords(from: data)
    totalRows += records.count
    for (index, record) in records.enumerated() {
        let prefix = "\(url.lastPathComponent) [\(index)] \(record.germanWord) (\(record.level))"
        if !validLevels.contains(record.level) {
            allErrors.append("\(prefix): invalid level \(record.level)")
        }
        if record.englishTranslation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            allErrors.append("\(prefix): empty englishTranslation")
        }
        if nounRowMissingArticle(category: record.category, article: record.article) {
            allErrors.append(
                "\(prefix): Noun row requires der/die/das article, got \(record.article ?? "nil")"
            )
        }
        if let reason = invalidGermanLemmaReason(for: record.germanWord) {
            allErrors.append("\(prefix): \(reason)")
        }
        if record.level == "A2" {
            let ex = record.exampleSentence?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if ex.isEmpty {
                allErrors.append("\(prefix): A2 row requires exampleSentence")
            }
            let art = normalizedArticle(record.article)
            if art == "der" || art == "die" || art == "das" {
                let pl = record.pluralSuffix?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if pl.isEmpty {
                    allErrors.append("\(prefix): A2 noun needs pluralSuffix")
                }
            }
        }
    }
}

if allErrors.isEmpty {
    let label = urlsToAudit.map { $0.lastPathComponent }.joined(separator: ", ")
    print("audit_data: OK — \(totalRows) rows across [\(label)]")
    exit(0)
}

fputs("audit_data: FAILED — \(allErrors.count) issue(s)\n", stderr)
for line in allErrors {
    fputs("  - \(line)\n", stderr)
}
exit(1)
