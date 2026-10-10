//
//  CompletionStore.swift
//  EverfitCalendar
//

import Foundation

protocol CompletionStoring: Sendable {
    func load() async throws -> [String: Bool]
    func setOverride(id: String, isCompleted: Bool) async throws
}

actor CompletionStore: CompletionStoring {

    static let fileName = "completion_overrides.json"

    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var memory: [String: Bool]?

    init(directory: URL = WorkoutsCache.documentsDirectory) {
        self.fileURL = directory.appendingPathComponent(Self.fileName)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func load() async throws -> [String: Bool] {
        try Task.checkCancellation()
        if let memory {
            return memory
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            memory = [:]
            return [:]
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let overrides = try decoder.decode([String: Bool].self, from: data)
            memory = overrides
            return overrides
        } catch is CancellationError {
            throw WorkoutsError.cancelled
        } catch {
            throw WorkoutsError.cacheCorrupted(error)
        }
    }

    func setOverride(id: String, isCompleted: Bool) async throws {
        try Task.checkCancellation()
        var current: [String: Bool]
        do {
            current = try await load()
        } catch {
            if Task.isCancelled { throw WorkoutsError.cancelled }
            current = memory ?? [:]
        }
        current[id] = isCompleted
        try persist(current)
    }

    private func persist(_ overrides: [String: Bool]) throws {
        do {
            let data = try encoder.encode(overrides)
            try data.write(to: fileURL, options: .atomic)
            memory = overrides
        } catch is CancellationError {
            throw WorkoutsError.cancelled
        } catch {
            throw WorkoutsError.cacheWriteFailed(error)
        }
    }
}
