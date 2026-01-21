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
            AppLogger.shared.location.error("Error1:\(String(describing: self.errorMessage))")
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
            self.errorMessage = WeatherError.invalidCityName.errorDescription
            self.weatherResponse = nil
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await service.fetchWeather(for: city)
            self.weatherResponse = response
            self.errorMessage = nil
        } catch WeatherError.invalidCityName {
            self.weatherResponse = nil
            self.errorMessage = WeatherError.invalidCityName.errorDescription
        } catch {
            self.weatherResponse = nil
            self.errorMessage = WeatherError.invalidWeatherData.errorDescription
        }
        
        self.isLoading = false
    }
    
    func loadWeatherIcon(iconStr: String) async -> UIImage? {
        do {
            let image = try await service.loadWeatherIcon(iconCode: iconStr)
            return image
        } catch {
            AppLogger.shared.location.error("Error3:\(String(describing: error))")
            return nil
        }
    }
}
