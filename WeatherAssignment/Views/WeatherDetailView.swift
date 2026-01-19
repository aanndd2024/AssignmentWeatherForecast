//
//  WeatherDetailView.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 18/01/26.
//

import SwiftUI

struct WeatherDetailView: View {
    let weather: WeatherResponse
    @ObservedObject var viewModel: WeatherViewModel
    @State private var weatherIcon: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // City & Country
                VStack(spacing: 8) {
                    Text(weather.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(weather.sys.country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(weather.name), \(weather.sys.country)")
                
                // Weather Icon
                Group {
                    if let icon = weatherIcon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .accessibilityLabel(weather.weather.first?.description.capitalized ?? "Weather condition")
                    } else {
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .accessibilityLabel("Loading weather icon")
                    }
                }
                
                // Temperature
                Text("\(Int(weather.main.temp))°F")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .accessibilityLabel("\(Int(weather.main.temp)) degrees Fahrenheit")
                
                // Feels Like
                Text("Feels like \(Int(weather.main.feelsLike))°F")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Feels like \(Int(weather.main.feelsLike)) degrees Fahrenheit")
                
                // Condition Description
                if let description = weather.weather.first?.description {
                    Text(description.capitalized)
                        .font(.title3)
                        .accessibilityLabel("Condition: \(description)")
                }
                
                // Humidity
                HStack {
                    Image(systemName: "drop.fill")
                    Text("Humidity: \(weather.main.humidity)%")
                }
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityLabel("Humidity \(weather.main.humidity) percent")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        // Async icon loading
        .task(id: weather) {
            weatherIcon = await viewModel.loadWeatherIcon(iconStr: weather.weather.first?.icon ?? "")
        }
    }
}
