//
//  WeatherResponse.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//

// Model/WeatherResponse.swift
import Foundation

struct WeatherResponse: Codable, Equatable {
    let id: Int
    let name: String
    let main: Main
    let weather: [WeatherItem]
    let sys: Sys

    struct Main: Codable, Equatable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp, humidity
            case feelsLike = "feels_like"
        }
    }

    struct WeatherItem: Codable, Equatable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct Sys: Codable, Equatable {
        let country: String
    }
}

