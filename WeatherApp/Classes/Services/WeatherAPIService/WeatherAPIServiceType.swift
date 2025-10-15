//
//  WeatherAPIServiceType.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

/// Протокол для работы с OpenWeather API
protocol WeatherAPIServiceType {
    func fetchWeather(for city: String) async throws -> WeatherEntity
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherEntity
    func fetchCitySuggestions(for query: String, limit: Int) async throws -> [GeoLocation]
}
