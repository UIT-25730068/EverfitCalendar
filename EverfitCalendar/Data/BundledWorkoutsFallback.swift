//
//  BundledWorkoutsFallback.swift
//  EverfitCalendar
//

import Foundation

protocol WorkoutsFallbackLoading {
    func loadFallback() throws -> WorkoutsResponseDTO
}

struct MissingResourceError: Error, LocalizedError {
    let name: String

    var errorDescription: String? {
        "Missing bundled resource \(name)"
    }
}

final class BundledWorkoutsFallback: WorkoutsFallbackLoading {

    private let bundle: Bundle
    private let resourceName: String
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, resourceName: String = "workouts_fallback") {
        self.bundle = bundle
        self.resourceName = resourceName
        self.decoder = JSONDecoder()
    }

    /// Sample week shipped in the app bundle. Used only after API **and** disk cache
    /// fail. Never written to `workouts_cache.json`.
    func loadFallback() throws -> WorkoutsResponseDTO {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw WorkoutsError.fallbackUnavailable(MissingResourceError(name: "\(resourceName).json"))
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(WorkoutsResponseDTO.self, from: data)
        } catch let error as WorkoutsError {
            throw error
        } catch {
            throw WorkoutsError.fallbackUnavailable(error)
        }
    }
}
