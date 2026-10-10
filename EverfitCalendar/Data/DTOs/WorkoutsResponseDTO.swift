//
//  WorkoutsResponseDTO.swift
//  EverfitCalendar
//

import Foundation

struct WorkoutsResponseDTO: Codable, Equatable, Sendable {
    let data: [DayDTO]
}

struct DayDTO: Codable, Equatable, Sendable {
    let id: String
    let day: Int
    let assignments: [AssignmentDTO]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case day
        case assignments
    }
}

struct AssignmentDTO: Codable, Equatable, Sendable {
    let id: String
    let title: String
    let status: Int
    let totalExercise: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case status
        case totalExercise = "total_exercise"
    }
}
