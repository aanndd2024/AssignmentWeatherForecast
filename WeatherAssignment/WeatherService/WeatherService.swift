//
//  WeatherService.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> WeatherResponse
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func loadWeatherIcon(iconCode: String) async throws -> UIImage
}

struct WeatherService: WeatherServiceProtocol {
    private let apiKey = "30b02809972df8e1e08d9dcc42b14f97"
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let url = makeURL(query: "q=\(city)")
        return try await networkManager.fetch(url)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let url = makeURL(query: "lat=\(latitude)&lon=\(longitude)")
        return try await networkManager.fetch(url)
    }
    
    private func makeURL(query: String) -> URL {
        URL(string: "https://api.openweathermap.org/data/2.5/weather?\(query)&units=imperial&appid=\(apiKey)")!
    }
}

extension WeatherServiceProtocol {
    func loadWeatherIcon(iconCode: String) async throws -> UIImage {
        guard !iconCode.isEmpty else {
            throw WeatherError.invalidURL
        }

        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else {
            throw WeatherError.invalidURL
        }

        do {
            return try await ImageCache.shared.loadImage(from: url)
        } catch {
            AppLogger.shared.network.error("Failed to load icon '\(iconCode)': \(error.localizedDescription)")
            throw WeatherError.invalidImageData
        }
    }
}
