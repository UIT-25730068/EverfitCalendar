//
//  WorkoutsAPIClient.swift
//  EverfitCalendar
//

import Foundation
import os

protocol WorkoutsFetching {
    func fetchWorkouts() async throws -> WorkoutsResponseDTO
}

final class WorkoutsAPIClient: WorkoutsFetching {

    static let defaultEndpoint = URL(string: "https://mock.internalef.com/workouts")!

    private let session: URLSession
    private let url: URL
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.ThanhND.EverfitCalendar", category: "Networking")

    init(
        session: URLSession? = nil,
        url: URL = WorkoutsAPIClient.defaultEndpoint
    ) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 30
            self.session = URLSession(configuration: configuration)
        }
        self.url = url
        self.decoder = JSONDecoder()
    }

    func fetchWorkouts() async throws -> WorkoutsResponseDTO {
        let data: Data
        let response: URLResponse

        do {
            try Task.checkCancellation()
            (data, response) = try await session.data(from: url)
        } catch {
            let mapped = WorkoutsError.fromTransport(error)
            logger.error("Fetch failed: \(mapped.localizedDescription, privacy: .public)")
            throw mapped
        }

        guard let http = response as? HTTPURLResponse else {
            logger.error("Invalid response (non-HTTP)")
            throw WorkoutsError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            logger.error("HTTP status \(http.statusCode)")
            throw WorkoutsError.httpStatus(http.statusCode)
        }

        do {
            return try decoder.decode(WorkoutsResponseDTO.self, from: data)
        } catch {
            logger.error("Decode failed: \(error.localizedDescription, privacy: .public)")
            throw WorkoutsError.decoding(error)
        }
    }
}
