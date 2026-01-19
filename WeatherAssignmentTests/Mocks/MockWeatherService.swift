//
//  MockWeatherService.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 19/01/26.
//
@testable import WeatherAssignment
import UIKit

struct MockWeatherService: WeatherServiceProtocol {
    var shouldError = false

    func fetchWeather(for city: String) async throws -> WeatherAssignment.WeatherResponse {
        if shouldError {
            throw WeatherError.invalidURL
        }
        return .mockWeatherResponse
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherAssignment.WeatherResponse {
        return .mockWeatherResponse
    }
    
    func loadWeatherIcon(iconCode: String) async throws -> UIImage {
        return UIImage(systemName: "cloud.sun.fill")!
    }
}


extension WeatherResponse {
    static let mockWeatherResponse = WeatherResponse(id: 1, name: "New York",
                                                     main: Main(temp: 72, feelsLike: 70, humidity: 55),
                                                     weather: [WeatherItem(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
                                                     sys: Sys(country: "US"))
}
