//
//  MainInteractor.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation
import CoreLocation

final class MainInteractor: MainInteractorProtocol {
    private let weatherAPIService: WeatherAPIServiceType

    init(weatherAPIService: WeatherAPIServiceType) {
        self.weatherAPIService = weatherAPIService
    }

    func fetchCitySuggestions(for query: String, completion: @escaping (Result<[GeoLocation], Error>) -> Void) {
        Task {
            do {
                let response = try await weatherAPIService.fetchCitySuggestions(for: query, limit: 5)
                print("✅ Cities fetched:", response.map { $0.name })

                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                print("❌ City fetch failed:", error)
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchCurrentWeather() async throws -> WeatherEntity {
        return try await fetchWeather(for: "Almaty")
    }

    func fetchWeather(for city: GeoLocation) async throws -> WeatherEntity {
        return try await fetchWeather(for: city.name)
    }

    func fetchWeather(for coordinates: CLLocationCoordinate2D) async throws -> WeatherEntity {
        return try await fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
    }

    private func fetchWeather(for cityName: String) async throws -> WeatherEntity {
        return try await weatherAPIService.fetchWeather(for: cityName)
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherEntity {
        return try await weatherAPIService.fetchWeather(lat: lat, lon: lon)
    }
}

// MARK: Private
extension MainInteractor {
    
}
