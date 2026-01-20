//
//  WeatherError.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case invalidImageData
    case invalidLocationStatus
    case httpStatus(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL"
        case .invalidResponse: return "Invalid Response"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode response"
        case .invalidImageData: return "Invalid image data"
        case .invalidLocationStatus: return "invalidLocationStatus"
        case .httpStatus(let code): return "Server error (\(code))"
        }
    }
}
