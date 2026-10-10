//
//  WorkoutsError.swift
//  EverfitCalendar
//

import Foundation

enum WorkoutsError: Error {
    case cancelled
    case network(URLError)
    case unexpected(Error)
    case httpStatus(Int)
    case invalidResponse
    case decoding(Error)
    case cacheMissing
    case cacheCorrupted(Error)
    case cacheWriteFailed(Error)
    case fallbackUnavailable(Error)
    case noDataAvailable(Error)

    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }

    var underlying: Error? {
        switch self {
        case .cancelled, .httpStatus, .invalidResponse, .cacheMissing:
            return nil
        case .network(let error):
            return error
        case .unexpected(let error),
             .decoding(let error),
             .cacheCorrupted(let error),
             .cacheWriteFailed(let error),
             .fallbackUnavailable(let error),
             .noDataAvailable(let error):
            return error
        }
    }

    static func fromTransport(_ error: Error) -> WorkoutsError {
        if error is CancellationError {
            return .cancelled
        }
        if let workoutsError = error as? WorkoutsError {
            return workoutsError
        }
        if let urlError = error as? URLError {
            if urlError.code == .cancelled {
                return .cancelled
            }
            return .network(urlError)
        }
        return .unexpected(error)
    }
}

extension WorkoutsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Request cancelled"
        case .network(let error):
            return "Network error: \(error.code.rawValue)"
        case .unexpected(let error):
            return "Unexpected transport error: \(error.localizedDescription)"
        case .httpStatus(let code):
            return "HTTP status \(code)"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .decoding(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .cacheMissing:
            return "Cache missing"
        case .cacheCorrupted(let error):
            return "Cache corrupted: \(error.localizedDescription)"
        case .cacheWriteFailed(let error):
            return "Cache write failed: \(error.localizedDescription)"
        case .fallbackUnavailable(let error):
            return "Fallback unavailable: \(error.localizedDescription)"
        case .noDataAvailable(let error):
            return "No data available: \(error.localizedDescription)"
        }
    }
}
