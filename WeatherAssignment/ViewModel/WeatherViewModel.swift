//
//  WeatherViewModel.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit

@MainActor
final class WeatherViewModel: ObservableObject {

    @Published var city: String = ""
    @Published var weather: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let service: WeatherServiceProtocol
    private let storage: UserDefaults

    init(service: WeatherServiceProtocol = WeatherService(networkManager: NetworkManager()), storage: UserDefaults) {
        self.service = service
        self.storage = storage
    }

    func loadLastCity() async {
        guard let savedCity = storage.string(forKey: "lastCity") else { return }
        city = savedCity
        await fetchWeatherData()
    }

    func fetchWeatherData() async {
        guard !city.isEmpty else {
            errorMessage = "Please enter a city name."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            weather = try await service.fetchWeather(for: city)
            print(weather)
            storage.set(city, forKey: "lastCity")
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func loadWeatherIcon(iconStr: String) async -> UIImage? {
        do {
            let image = try await service.loadWeatherIcon(iconCode: iconStr)
            return image
        } catch {
            print("Failed to load icon:", error)
            return nil
        }
    }
}
