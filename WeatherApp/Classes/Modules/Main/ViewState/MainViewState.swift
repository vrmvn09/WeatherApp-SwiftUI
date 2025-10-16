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
    
    // UI State
    @Published var searchText = ""
    @Published var gradientShift: Double = 0.0
    @Published var keyboardHeight: CGFloat = 0
    @Published var isEditing: Bool = false
    @Published var didNavigateFromLocation = false
    @Published var shouldNavigateOnLocation = true
    
    // Location Service
    private let locationService: LocationServiceType
    
    init(locationService: LocationServiceType) {
        self.locationService = locationService
    }

    
    func set(with presener: MainPresenterProtocol) {
        self.presenter = presener
        presenter?.loadSavedCities()
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
        self.savedCities = cities
        presenter?.saveSavedCities(cities)
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
        presenter?.persistLastLocation(coords)
    }
    
    func loadLastLocation() -> CLLocationCoordinate2D? {
        return presenter?.loadLastLocation()
    }
    
    // MARK: - Location Service Methods
    func requestLocationPermission() {
        locationService.requestPermission()
    }
    
    func requestLocation() {
        locationService.requestLocation()
    }
    
    var locationPublisher: Published<CLLocationCoordinate2D?>.Publisher {
        locationService.locationPublisher
    }
}
