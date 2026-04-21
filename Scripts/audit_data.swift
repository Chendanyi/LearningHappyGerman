#!/usr/bin/env swift
// Standalone data audit for `german_vocabulary.json` (Goethe extractor output, array of records).
// Run: swift Scripts/audit_data.swift [optional/path/to/german_vocabulary.json]
//
// Rules: rows with type "noun" must have der/die/das; `word` must use Latin-script characters
// acceptable for German lemmas (umlauts, ß, hyphen, apostrophe, spaces).
import Foundation

// MARK: - Payload (aligned with extract_vocab.py export)

struct GermanVocabularyJSONRecord: Codable {
    let word: String
    let type: String
    let level: String
    let examples: [String]?
    let article: String?
    let plural: String?
    let conjugation: String?
    let auxiliary: String?
    let perfect: String?
    let englishTranslation: String?
}

// MARK: - Rules

private let validLevels: Set<String> = ["A1", "A2", "B1", "B2", "C1", "C2"]

private func normalizedArticle(_ article: String?) -> String? {
    guard let article else { return nil }
    let trimmed = article.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty || trimmed.lowercased() == "none" { return nil }
    return trimmed.lowercased()
}

private func nounRowMissingArticle(type: String, article: String?) -> Bool {
    guard type.lowercased() == "noun" else { return false }
    guard let art = normalizedArticle(article) else { return true }
    return !(art == "der" || art == "die" || art == "das")
}

private func invalidGermanLemmaReason(for word: String) -> String? {
    for scalar in word.unicodeScalars {
        let v = scalar.value
        if CharacterSet.whitespaces.contains(scalar) {
            continue
        }
        if v == 0x002D || v == 0x2010 || v == 0x2011 || v == 0x0027 || v == 0x2019 || v == 0x00B7 {
            continue
        }
        if (0x0041...0x005A).contains(v) || (0x0061...0x007A).contains(v) {
            continue
        }
        if (0x00C0...0x024F).contains(v) {
            continue
        }
        if (0x1E00...0x1EFF).contains(v) {
            continue
        }
        if v == 0x00DF || v == 0x1E9E {
            continue
        }
        if (0x0030...0x0039).contains(v) {
            return "unexpected digit U+\(String(v, radix: 16, uppercase: true))"
        }
        return "invalid character U+\(String(v, radix: 16, uppercase: true)) in \(word.debugDescription)"
    }
    return nil
}

private func resolveDefaultVocabularyURLs() -> [URL] {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    let url = cwd.appendingPathComponent("Data/german_vocabulary.json")
    if FileManager.default.fileExists(atPath: url.path) {
        return [url]
    }
    return []
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
        "audit_data: no Data/german_vocabulary.json found (skipped).\n",
        stderr
    )
    exit(0)
}

var allErrors: [String] = []
var totalRows = 0
let decoder = JSONDecoder()
do {
    for url in urlsToAudit {
        guard FileManager.default.fileExists(atPath: url.path) else {
            allErrors.append("missing file \(url.path)")
            continue
        }
        let data = try Data(contentsOf: url)
        let records = try decoder.decode([GermanVocabularyJSONRecord].self, from: data)
        totalRows += records.count
        for (index, record) in records.enumerated() {
            let prefix = "\(url.lastPathComponent) [\(index)] \(record.word) (\(record.level))"
            if !validLevels.contains(record.level) {
                allErrors.append("\(prefix): invalid level \(record.level)")
            }
            if nounRowMissingArticle(type: record.type, article: record.article) {
                allErrors.append("\(prefix): noun requires der/die/das, got \(record.article ?? "nil")")
            }
            if let reason = invalidGermanLemmaReason(for: record.word) {
                allErrors.append("\(prefix): \(reason)")
            }
        }
    }
} catch {
    fputs("audit_data: decode error — \(error)\n", stderr)
    exit(1)
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
