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
    private let locationService: LocationServiceType
    
    // Storage keys
    private let storageKey = "savedCities"
    private let lastLocationKey = "lastLocation"
    
    // File URL for saved cities
    private var savedCitiesFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("saved_cities.json")
    }

    init(weatherAPIService: WeatherAPIServiceType, locationService: LocationServiceType) {
        self.weatherAPIService = weatherAPIService
        self.locationService = locationService
    }

    func fetchCitySuggestions(for query: String, completion: @escaping (Result<[GeoLocation], Error>) -> Void) {
        Task {
            do {
                let response = try await weatherAPIService.fetchCitySuggestions(for: query, limit: 5)

                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
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

// MARK: - Data Persistence
extension MainInteractor {
    
    func loadLastLocation() -> CLLocationCoordinate2D? {
        guard let dict = UserDefaults.standard.dictionary(forKey: lastLocationKey) as? [String: Double],
              let lat = dict["lat"], let lon = dict["lon"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func persistLastLocation(_ coords: CLLocationCoordinate2D) {
        let dict: [String: Double] = ["lat": coords.latitude, "lon": coords.longitude]
        UserDefaults.standard.set(dict, forKey: lastLocationKey)
    }
    
    func saveSavedCities(_ cities: [GeoLocation]) {
        do {
            let data = try JSONEncoder().encode(cities)
            UserDefaults.standard.set(data, forKey: storageKey)
            // Also persist to file to survive edge cases/reinstalls
            try? data.write(to: savedCitiesFileURL, options: .atomic)
        } catch {
            // Handle error silently
        }
    }
    
    func loadSavedCities() -> [GeoLocation] {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let cities = try JSONDecoder().decode([GeoLocation].self, from: data)
                return cities
            } catch {
                // Handle error silently
            }
        }
        // Fallback to file (e.g., after certain reinstall scenarios)
        if let data = try? Data(contentsOf: savedCitiesFileURL),
           let cities = try? JSONDecoder().decode([GeoLocation].self, from: data) {
            return cities
        }
        return []
    }
    
    // MARK: - Location Service Methods
    func requestLocationPermission() {
        locationService.requestPermission()
    }
    
    func requestLocation() {
        locationService.requestLocation()
    }
    
    func setLocationCallback(_ callback: @escaping (CLLocationCoordinate2D?) -> Void) {
        locationService.setLocationCallback(callback)
    }
    
    func setPermissionGrantedCallback(_ callback: @escaping () -> Void) {
        locationService.setPermissionGrantedCallback(callback)
    }
    
    // MARK: - Navigation State Management
    func resetNavigationFlag() {
        // This method is not needed in Interactor as it's handled in ViewState
        // But we need to implement it to conform to protocol
    }
}
