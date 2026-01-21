//
//  WeatherViewModel.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit
import CoreLocation

@MainActor
final class WeatherViewModel: ObservableObject {
    
    @Published var city: String = ""
    @Published var weatherResponse: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let service: WeatherServiceProtocol
    private var locationService: LocationServiceProtocol
    private let storage: UserDefaults
    
    init(service: WeatherServiceProtocol = WeatherService(networkManager: NetworkManager()), storage: UserDefaults, locationService: LocationServiceProtocol) {
        self.service = service
        self.storage = storage
        self.locationService = locationService
    }
    
    func requestLocationPermissionAndLoad() {
        locationService.onAuthorizationChange = { [weak self] status in
            Task {
                await self?.handleAuthorization(status)
            }
        }
        locationService.requestLocationPermission()
    }
    
    private func handleAuthorization(_ status: CLAuthorizationStatus) async {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            await loadWeatherByLocation()
        case .denied, .restricted:
            await loadLastCity()
        default:
            break
        }
    }
    
    private func loadWeatherByLocation() async {
        isLoading = true
        errorMessage = nil
        do {
            let coordinate = try await locationService.getCurrentLocation()
            weatherResponse = try await service.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
            AppLogger.shared.location.info("Weather Information: \(String(describing: self.weatherResponse))")
        } catch {
            errorMessage = error.localizedDescription
            await loadLastCity()
        }
        isLoading = false
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
            weatherResponse = try await service.fetchWeather(for: city)
            //print(weather)
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
