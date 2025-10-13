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
    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol) {
        self.network = network
    }

    func fetchCitySuggestions(for query: String, completion: @escaping (Result<[GeoLocation], Error>) -> Void) {
        Task {
            do {
                let url = try OpenWeatherAPI.citySearch(for: query)
                print("🌍 Fetching cities from:", url.absoluteString)
                
                let response: [GeoLocation] = try await network.request(url)
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
        let url = try OpenWeatherAPI.weather(for: cityName)
        let weather: WeatherResponse = try await network.request(url)
        
        return WeatherEntity(
            city: weather.name,
            temperature: weather.main.temp,
            description: weather.weather.first?.description ?? "",
            icon: weather.weather.first?.icon ?? "",
            conditionName: weather.weather.first?.main ?? "Clear",
            humidity: weather.main.humidity,
            windSpeed: weather.wind.speed,
            feelsLike: weather.main.feels_like,
            pressure: weather.main.pressure,
            sunrise: Date(timeIntervalSince1970: weather.sys.sunrise),
            sunset: Date(timeIntervalSince1970: weather.sys.sunset)
        )
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherEntity {
        let url = try OpenWeatherAPI.weather(lat: lat, lon: lon)
        let weather: WeatherResponse = try await network.request(url)
        
        return WeatherEntity(
            city: weather.name,
            temperature: weather.main.temp,
            description: weather.weather.first?.description ?? "",
            icon: weather.weather.first?.icon ?? "",
            conditionName: weather.weather.first?.main ?? "Clear",
            humidity: weather.main.humidity,
            windSpeed: weather.wind.speed,
            feelsLike: weather.main.feels_like,
            pressure: weather.main.pressure,
            sunrise: Date(timeIntervalSince1970: weather.sys.sunrise),
            sunset: Date(timeIntervalSince1970: weather.sys.sunset)
        )
    }
}

// MARK: Private
extension MainInteractor {
    
}
