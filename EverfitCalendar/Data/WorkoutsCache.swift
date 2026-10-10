//
//  WorkoutsCache.swift
//  EverfitCalendar
//

import Foundation

protocol WorkoutsCaching: Sendable {
    func load() async throws -> WorkoutsResponseDTO?
    func save(_ dto: WorkoutsResponseDTO) async throws
}

/// Last **valid** API payload (`workouts_cache.json` in Documents).
/// Written only after a successful 2xx decode. Corrupt files throw
/// `cacheCorrupted` and must not be treated as a week. Bundled fallback
/// is never saved here, so it cannot masquerade as server data on the next launch.
actor WorkoutsCache: WorkoutsCaching {

    static let fileName = "workouts_cache.json"

    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var memory: WorkoutsResponseDTO?

    init(directory: URL = WorkoutsCache.documentsDirectory) {
        self.fileURL = directory.appendingPathComponent(Self.fileName)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            // Existing directories succeed; a real failure is surfaced on the next save/load.
        }
    }

    /// Returns the in-memory copy if present; otherwise reads disk.
    /// No file → `nil` (cold start). Decode/IO failure → `cacheCorrupted`.
    func load() async throws -> WorkoutsResponseDTO? {
        try Task.checkCancellation()
        if let memory {
            return memory
        }

        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let dto = try decoder.decode(WorkoutsResponseDTO.self, from: data)
            memory = dto
            return dto
        } catch is CancellationError {
            throw WorkoutsError.cancelled
        } catch {
            throw WorkoutsError.cacheCorrupted(error)
        }
    }

    /// Atomic replace of the payload file, then updates the in-memory copy.
    /// A failed write must not leave a half-written JSON file.
    func save(_ dto: WorkoutsResponseDTO) async throws {
        try Task.checkCancellation()
        do {
            let data = try encoder.encode(dto)
            try data.write(to: fileURL, options: .atomic)
            memory = dto
        } catch is CancellationError {
            throw WorkoutsError.cancelled
        } catch {
            throw WorkoutsError.cacheWriteFailed(error)
        }
    }

    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
