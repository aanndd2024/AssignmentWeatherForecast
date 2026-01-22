//
//  WeatherService.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async -> Result<WeatherResponse, WeatherError>
    func fetchWeather(latitude: Double, longitude: Double) async -> Result<WeatherResponse, WeatherError>
    func loadWeatherIcon(iconCode: String) async -> Result<UIImage, WeatherError>
}

struct WeatherService: WeatherServiceProtocol {
    private let apiKey = "30b02809972df8e1e08d9dcc42b14f97"
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchWeather(for city: String) async -> Result<WeatherResponse, WeatherError> {
        let url = makeURL(query: "q=\(city)")
        do {
            let weather: WeatherResponse = try await networkManager.fetch(url)
            return .success(weather)
        } catch let error as WeatherError {
            return .failure(error)
        } catch {
            return .failure(.invalidResponse)
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async -> Result<WeatherResponse, WeatherError> {
        let url = makeURL(query: "lat=\(latitude)&lon=\(longitude)")
        do {
            let weather: WeatherResponse = try await networkManager.fetch(url)
            return .success(weather)
        } catch let error as WeatherError {
            return .failure(error)
        } catch {
            return .failure(.invalidResponse)
        }
    }
    
    private func makeURL(query: String) -> URL {
        URL(string: "https://api.openweathermap.org/data/2.5/weather?\(query)&units=imperial&appid=\(apiKey)")!
    }
}

extension WeatherServiceProtocol {
    func loadWeatherIcon(iconCode: String) async -> Result<UIImage, WeatherError> {
        // 1. Validate icon code
        guard !iconCode.isEmpty else {
            return .failure(.invalidURL)
        }
        // 2. Construct the URL
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else {
            return .failure(.invalidURL)
        }
        // 3. Try to load the image asynchronously
        do {
            let image = try await ImageCache.shared.loadImage(from: url)
            return .success(image)
        } catch {
            // 4. Log and return failure
            AppLogger.shared.network.error("Failed to load icon '\(iconCode)': \(error.localizedDescription)")
            return .failure(.invalidImageData)
        }
    }
}
