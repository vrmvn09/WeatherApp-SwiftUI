//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case requestFailed
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL."
        case .invalidResponse: return "Server returned invalid response."
        case .decodingError: return "Failed to decode server data."
        case .requestFailed: return "Network request failed."
        case .missingAPIKey: return "Missing or invalid API key."
        }
    }
}

final class WeatherAPIService: WeatherAPIServiceType {
    
    private let networkService: NetworkServiceType
    
    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }
    
    func fetchWeather(for city: String) async throws -> WeatherEntity {
        let url = try OpenWeatherAPI.weather(for: city)
        let weather: WeatherResponse = try await networkService.request(url)
        
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
        let weather: WeatherResponse = try await networkService.request(url)
        
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
    
    func fetchCitySuggestions(for query: String, limit: Int = 5) async throws -> [GeoLocation] {
        let url = try OpenWeatherAPI.citySearch(for: query, limit: limit)
        let suggestions: [GeoLocationResponse] = try await networkService.request(url)
        
        return suggestions.map { response in
            GeoLocation(
                name: response.name,
                lat: response.lat,
                lon: response.lon,
                country: response.country
            )
        }
    }
}

// MARK: - API Response Models
private struct WeatherResponse: Codable {
    let name: String
    let weather: [WeatherInfo]
    let main: MainInfo
    let wind: WindInfo
    let sys: SystemInfo
}

private struct WeatherInfo: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

private struct MainInfo: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
    let pressure: Int
}

private struct WindInfo: Codable {
    let speed: Double
}

private struct SystemInfo: Codable {
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

private struct GeoLocationResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}

// MARK: - OpenWeather API
private enum OpenWeatherAPI {
    static let baseURL = "https://api.openweathermap.org"
    static let units = "metric"
    
    private static func apiKey() throws -> String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !key.isEmpty {
            return key
        }
        throw NetworkError.missingAPIKey
    }
    
    static func citySearch(for query: String, limit: Int = 5) throws -> URL {
        let key = try apiKey()
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        let urlString = "\(baseURL)/geo/1.0/direct?q=\(encoded)&limit=\(limit)&appid=\(key)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        return url
    }

    static func weather(for city: String) throws -> URL {
        let key = try apiKey()
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        guard let url = URL(string: "\(baseURL)/data/2.5/weather?q=\(encodedCity)&appid=\(key)&units=\(units)") else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    static func weather(lat: Double, lon: Double) throws -> URL {
        let key = try apiKey()
        guard let url = URL(string: "\(baseURL)/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(key)&units=\(units)") else {
            throw NetworkError.invalidURL
        }
        return url
    }
}
