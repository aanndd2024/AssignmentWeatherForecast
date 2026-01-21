//
//  SearchView.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 18/01/26.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var isEditing = false // Optional: track focus if needed

    var body: some View {
        VStack {
            SearchTextField(
                text: $viewModel.city,
                placeholder: "Enter a US city"
            ) {
                Task { await viewModel.fetchWeatherData() }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.top)

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading weather data…")
                        .progressViewStyle(.circular)
                        .accessibilityLabel("Loading weather data")
                } else if let weather = viewModel.weatherResponse {
                    WeatherDetailView(weather: weather, viewModel: viewModel)
                } else {
                    contentPlaceholder
                }
            }
            .padding(.top, 8)
        }
        .onChange(of: viewModel.city) { _, newValue in
            if !newValue.isEmpty {
                viewModel.errorMessage = nil
            }
        }
    }

    private var contentPlaceholder: some View {
        VStack(spacing: 24) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
                .accessibilityHidden(true)

            Text("Search for a US city")
                .font(.title2)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Search for a United States city to view weather")

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
        .padding()
    }
}
//#Preview {
//    let networkManager = NetworkManager()
//    let service = WeatherService(networkManager: networkManager)
//    let viewModel = WeatherViewModel(service: service, storage: .standard, locationService: <#any LocationServiceProtocol#>)
//    SearchView(viewModel: viewModel)
//}
