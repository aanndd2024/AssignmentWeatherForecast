//
//  SearchView.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 18/01/26.
//

// Views/SearchView.swift
import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading weather data…")
                    .progressViewStyle(.circular)
                    .accessibilityLabel("Loading weather data")
            } else if let weather = viewModel.weather {
                WeatherDetailView(weather: weather, viewModel: viewModel)
            } else {
                contentPlaceholder
            }
        }
        .searchable(text: $viewModel.city,
                   isPresented: $isSearching,
                   prompt: "Enter a US city")
        .onSubmit(of: .search) {
            Task {
                await viewModel.fetchWeatherData()
            }
        }
        .onChange(of: viewModel.city) { _, newValue in
            // Clear error when user types
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
#Preview {
    let networkManager = NetworkManager()
    let service = WeatherService(networkManager: networkManager)
    let viewModel = WeatherViewModel(service: service, storage: .standard)
    SearchView(viewModel: viewModel)
}
