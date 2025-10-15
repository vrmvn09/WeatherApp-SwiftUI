//
//  MainViewState.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI
import CoreLocation

// MARK: - Weather Entities
struct WeatherEntity: Identifiable, Equatable {
    let id = UUID()
    let city: String
    let temperature: Double
    let description: String
    let icon: String
    let conditionName: String
    let humidity: Int
    let windSpeed: Double
    let feelsLike: Double
    let pressure: Int
    let sunrise: Date
    let sunset: Date
}

struct GeoLocation: Codable, Hashable, Identifiable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String

    var id: String { "\(name)-\(country)-\(lat)-\(lon)" }
}

final class MainViewState: ObservableObject, MainViewStateProtocol {    
    private let id = UUID()
    var presenter: MainPresenterProtocol?
    
    // Weather data
    @Published var weather: WeatherEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var citySuggestions: [GeoLocation] = []
    @Published var savedCities: [GeoLocation] = []

    private let storageKey = "savedCities"
    private let lastLocationKey = "lastLocation"
    private var savedCitiesFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("saved_cities.json")
    }
    
    func set(with presener: MainPresenterProtocol) {
        self.presenter = presener
        loadSavedCities()
    }
    
    // Methods to update weather data
    func updateWeather(_ weather: WeatherEntity) {
        self.weather = weather
    }
    
    func updateLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func updateErrorMessage(_ message: String?) {
        self.errorMessage = message
    }
    
    func updateCitySuggestions(_ suggestions: [GeoLocation]) {
        self.citySuggestions = suggestions
    }

    func updateSavedCities(_ cities: [GeoLocation]) {
        print("💾 Updating saved cities: \(cities.map { $0.name })")
        self.savedCities = cities
        saveSavedCities()
    }
    
    // MARK: - User Actions (delegate to presenter)
    func fetchWeatherFromText(_ text: String) {
        presenter?.fetchWeatherFromText(text)
    }
    
    func updateSuggestions(for text: String) {
        presenter?.updateSuggestions(for: text)
    }
    
    func removeCity(_ city: GeoLocation) {
        presenter?.removeCity(city)
    }
    
    func selectCity(_ city: GeoLocation) {
        presenter?.selectCity(city)
    }
    
    func addCityToList(_ city: GeoLocation) {
        presenter?.addCityToList(city)
    }
    
    func onAppear() {
        presenter?.onAppear()
    }
    
    func fetchWeatherForLocationAndNavigate(_ coords: CLLocationCoordinate2D) {
        presenter?.fetchWeatherForLocationAndNavigate(coords)
    }

    func persistLastLocation(_ coords: CLLocationCoordinate2D) {
        let dict: [String: Double] = ["lat": coords.latitude, "lon": coords.longitude]
        UserDefaults.standard.set(dict, forKey: lastLocationKey)
    }
    
    func loadLastLocation() -> CLLocationCoordinate2D? {
        guard let dict = UserDefaults.standard.dictionary(forKey: lastLocationKey) as? [String: Double],
              let lat = dict["lat"], let lon = dict["lon"] else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func saveSavedCities() {
        do {
            let data = try JSONEncoder().encode(savedCities)
            UserDefaults.standard.set(data, forKey: storageKey)
            // Also persist to file to survive edge cases/reinstalls
            try? data.write(to: savedCitiesFileURL, options: .atomic)
        } catch {
            print("Failed to save cities: \(error)")
        }
    }
    
    private func loadSavedCities() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let cities = try JSONDecoder().decode([GeoLocation].self, from: data)
                self.savedCities = cities
                return
            } catch {
                print("Failed to load cities from defaults: \(error)")
            }
        }
        // Fallback to file (e.g., after certain reinstall scenarios)
        if let data = try? Data(contentsOf: savedCitiesFileURL),
           let cities = try? JSONDecoder().decode([GeoLocation].self, from: data) {
            self.savedCities = cities
        }
    }
}
