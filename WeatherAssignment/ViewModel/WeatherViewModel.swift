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
            // Use Result-based fetchWeather
            let weatherResult = await service.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
            switch weatherResult {
            case .success(let weather):
                weatherResponse = weather
                AppLogger.shared.location.info("Weather Information: \(String(describing: self.weatherResponse))")
            case .failure(let error):
                errorMessage = error.localizedDescription
                AppLogger.shared.location.error("Weather fetch failed: Error:\(String(describing: self.errorMessage))")
                await loadLastCity()
            }
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.shared.location.error("Location fetch failed: Error:\(String(describing: self.errorMessage))")
            await loadLastCity()
        }
        
        isLoading = false
    }
    
    
    func loadLastCity() async {
        guard let savedCity = storage.string(forKey: "lastCity") else {
            return
        }
        city = savedCity
        await fetchWeatherData()
    }
    
    func fetchWeatherData() async {
        // 1. Validate city
        guard !city.isEmpty else {
            self.errorMessage = WeatherError.invalidCityName.errorDescription
            self.weatherResponse = nil
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        // 2. Call Result-based service
        let result = await service.fetchWeather(for: city)
        
        switch result {
        case .success(let response):
            self.weatherResponse = response
            self.errorMessage = nil
        case .failure(let error):
            self.weatherResponse = nil
            switch error {
            case .invalidCityName:
                self.errorMessage = WeatherError.invalidCityName.errorDescription
                AppLogger.shared.location.error("Location fetch failed: Error:\(String(describing: self.errorMessage))")
            default:
                self.errorMessage = WeatherError.invalidWeatherData.errorDescription
                AppLogger.shared.location.error("Location fetch failed: Error:\(String(describing: self.errorMessage))")
            }
        }
        
        self.isLoading = false
    }
    
    func loadWeatherIcon(iconCode: String) async -> UIImage? {
        let result = await service.loadWeatherIcon(iconCode: iconCode)
        switch result {
        case .success(let image):
            return image
        case .failure(let error):
            AppLogger.shared.location.error("loadWeatherIcon() Error:\(String(describing: error))")
            return nil
        }
    }
}
