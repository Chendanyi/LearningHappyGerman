import Foundation
import SwiftData

// MARK: - Remote payload (API contract; no per-user fields)

/// Vocabulary snapshot delivered by a future sync API. User progress fields (`isMastered`) are intentionally omitted.
struct RemoteVocabularyPayload: Codable, Sendable {
    let version: Int
    let words: [RemoteWordDTO]
}

struct RemoteWordDTO: Codable, Sendable, Equatable {
    let germanWord: String
    let article: String
    let englishTranslation: String
    let level: String
    let category: String
    let version: Int?
}

/// Result of merging remote rows into the local store.
struct SyncMergeResult: Sendable {
    let insertedCount: Int
    let updatedCount: Int
}

// MARK: - SyncService (placeholder)

/// Placeholder sync pipeline: fetch remote JSON and merge into `ModelContext` without duplicate rows.
///
/// **Merge key:** `(germanWord, CEFRLevel)` — one logical card per headword per level.
/// - Existing rows: update editorial fields from remote; **preserve** `isMastered`.
/// - New rows: insert with `isMastered == false`.
enum SyncService {
    /// Fetches JSON from a remote URL (placeholder for a future authenticated API).
    static func fetchRemotePayload(from url: URL) async throws -> RemoteVocabularyPayload {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw SyncServiceError.unexpectedHTTP
        }
        return try decodeRemotePayload(from: data)
    }

    static func decodeRemotePayload(from data: Data) throws -> RemoteVocabularyPayload {
        try JSONDecoder().decode(RemoteVocabularyPayload.self, from: data)
    }

    /// Merges remote words into the store. Does not create a second row for the same `(germanWord, level)`.
    static func mergeRemotePayload(
        _ payload: RemoteVocabularyPayload,
        into context: ModelContext
    ) throws -> SyncMergeResult {
        let descriptor = FetchDescriptor<VocabularyWord>()
        let existing = try context.fetch(descriptor)

        var byKey: [String: VocabularyWord] = [:]
        for word in existing {
            byKey[Self.stableKey(germanWord: word.germanWord, level: word.level)] = word
        }

        var inserted = 0
        var updated = 0

        for dto in payload.words {
            guard let article = GermanArticle(rawValue: dto.article) else {
                throw SyncServiceError.invalidRemoteField("article for \(dto.germanWord)")
            }
            guard let level = CEFRLevel(rawValue: dto.level) else {
                throw SyncServiceError.invalidRemoteField("level for \(dto.germanWord)")
            }
            guard let category = WordCategory(rawValue: dto.category) else {
                throw SyncServiceError.invalidRemoteField("category for \(dto.germanWord)")
            }

            let key = Self.stableKey(germanWord: dto.germanWord, level: level)
            let remoteVersion = dto.version ?? payload.version

            if let local = byKey[key] {
                local.article = article
                local.englishTranslation = dto.englishTranslation
                local.category = category
                local.version = max(local.version, remoteVersion)
                // isMastered intentionally not modified — user progress is preserved.
                updated += 1
            } else {
                let word = VocabularyWord(
                    germanWord: dto.germanWord,
                    article: article,
                    englishTranslation: dto.englishTranslation,
                    level: level,
                    category: category,
                    isMastered: false,
                    version: remoteVersion
                )
                context.insert(word)
                byKey[key] = word
                inserted += 1
            }
        }

        try context.save()
        return SyncMergeResult(insertedCount: inserted, updatedCount: updated)
    }

    static func stableKey(germanWord: String, level: CEFRLevel) -> String {
        "\(germanWord)|\(level.rawValue)"
    }
}

enum SyncServiceError: LocalizedError {
    case unexpectedHTTP
    case invalidRemoteField(String)

    var errorDescription: String? {
        switch self {
        case .unexpectedHTTP:
            return "Unexpected HTTP response when fetching remote vocabulary."
        case .invalidRemoteField(let detail):
            return "Invalid remote field: \(detail)"
        }
    }
}
