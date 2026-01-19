//
//  NetworkManager.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation

protocol NetworkManagerProtocol {
    func fetch<T: Decodable>(_ url: URL) async throws -> T
}

struct NetworkManager: NetworkManagerProtocol {
    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw WeatherError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
}
