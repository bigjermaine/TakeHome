//
//  NetworkError.swift
//  TakeHome
//
//  Created by jermaine daniel on 16/06/2026.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Invalid URL.")
        case .invalidResponse:
            return String(localized: "Invalid server response.")
        case .httpStatus(let code):
            return String(format: String(localized: "Server error (%lld)."), Int64(code))
        case .decodingFailed:
            return String(localized: "Failed to decode response.")
        }
    }
}
