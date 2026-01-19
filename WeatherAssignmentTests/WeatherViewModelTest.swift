//
//  WeatherViewModelTest.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 19/01/26.
//

import Testing
@testable import WeatherAssignment
import Foundation

@MainActor
struct WeatherViewModelTests {

    // MARK: - Success Case

    @Test
    func fetchWeather_success_updatesWeatherAndStopsLoading() async {
        let service = MockWeatherService()
        let storage = UserDefaults(suiteName: "WeatherTestSuite")!
        storage.removePersistentDomain(forName: "WeatherTestSuite")

        let viewModel = WeatherViewModel(
            service: service,
            storage: storage
        )
        viewModel.city = "New York"

        await viewModel.fetchWeatherData()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.weather?.name == "New York")
        #expect(viewModel.errorMessage == nil)
        #expect(storage.string(forKey: "lastCity") == "New York")
    }

    // MARK: - Validation Case

    @Test
    func fetchWeather_emptyCity_setsErrorMessage() async {
        let service = MockWeatherService()
        let storage = UserDefaults(suiteName: "WeatherTestSuite")!

        let viewModel = WeatherViewModel(
            service: service,
            storage: storage
        )

        await viewModel.fetchWeatherData()

        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage == "Please enter a city name.")
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Failure Case

    @Test
    func fetchWeather_failure_setsErrorMessage() async {
        let service = MockWeatherService(shouldError: true)
        let storage = UserDefaults(suiteName: "WeatherTestSuite")!

        let viewModel = WeatherViewModel(
            service: service,
            storage: storage
        )
        viewModel.city = "InvalidCity"

        await viewModel.fetchWeatherData()

        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Persistence Case

    @Test
    func loadLastCity_readsFromUserDefaultsAndFetchesWeather() async {
        let service = MockWeatherService()
        let storage = UserDefaults(suiteName: "WeatherTestSuite")!
        storage.set("Chicago", forKey: "lastCity")

        let viewModel = WeatherViewModel(
            service: service,
            storage: storage
        )

        await viewModel.loadLastCity()

        #expect(viewModel.city == "Chicago")
        #expect(viewModel.weather?.name == "New York") // mock response
    }

    // MARK: - Icon Loading

    @Test
    func loadWeatherIcon_returnsImage() async {
        let service = MockWeatherService()
        let storage = UserDefaults(suiteName: "WeatherTestSuite")!

        let viewModel = WeatherViewModel(
            service: service,
            storage: storage
        )

        let image = await viewModel.loadWeatherIcon(iconStr: "01d")

        #expect(image != nil)
    }
}
