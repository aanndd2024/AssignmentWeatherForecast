//
//  ContentView.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//

import SwiftUI

struct WeatherAppView: View {
    @StateObject private var viewModel: WeatherViewModel

    init(storage: UserDefaults = .standard) {
        let service = WeatherService(networkManager: NetworkManager())
        _viewModel = StateObject(
            wrappedValue: WeatherViewModel(service: service, storage: storage))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SearchView(viewModel: viewModel)
                    .navigationTitle("Weather")
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1.2)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
        .task {
            await viewModel.loadLastCity()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Weather application")
    }
}

#Preview {
    WeatherAppView()
}
