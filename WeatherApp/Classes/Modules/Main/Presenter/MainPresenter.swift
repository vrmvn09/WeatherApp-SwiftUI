//
//  MainPresenter.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI
import CoreLocation

final class MainPresenter: MainPresenterProtocol {
    
    private let router: MainRouterProtocol
    private weak var viewState: MainViewStateProtocol?
    private let interactor: MainInteractorProtocol
    
    private let allCities: [GeoLocation] = [
        GeoLocation(name: "Almaty", lat: 43.222, lon: 76.851, country: "KZ"),
        GeoLocation(name: "Astana", lat: 51.169, lon: 71.449, country: "KZ"),
        GeoLocation(name: "Shymkent", lat: 42.341, lon: 69.590, country: "KZ"),
        GeoLocation(name: "Almaly", lat: 43.0, lon: 76.9, country: "KZ"),
    ]
    
    init(router: MainRouterProtocol,
         interactor: MainInteractorProtocol,
         viewState: MainViewStateProtocol) {
        self.router = router
        self.interactor = interactor
        self.viewState = viewState
        
        // Interactor не должен иметь ссылку на Presenter согласно VIPER архитектуре
    }
    
    func onAppear() {
        // Do not auto-fetch weather on launch; show empty state with search and saved list
        // ViewState уже загружает сохраненные города при инициализации
    }
    
    func updateSuggestions(for text: String) {
        guard !text.isEmpty else {
            viewState?.updateCitySuggestions([])
            return
        }
        
        interactor.fetchCitySuggestions(for: text) { [weak self] result in
            switch result {
            case .success(let cities):
                self?.viewState?.updateCitySuggestions(cities)
            case .failure(let error):
                self?.viewState?.updateCitySuggestions([])
            }
        }
    }
    
    func selectCity(_ city: GeoLocation) {
        viewState?.updateLoading(true)
        
        Task {
            do {
                let weather: WeatherEntity
                if city.name == "My Location" {
                    weather = try await interactor.fetchWeather(lat: city.lat, lon: city.lon)
                } else {
                    weather = try await interactor.fetchWeather(for: city)
                }
                
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateWeather(weather)
                    viewState?.updateCitySuggestions([])
                    router.showWeatherDetail(for: weather, city: city)
                }
            } catch {
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateErrorMessage(error.localizedDescription)
                    viewState?.updateCitySuggestions([])
                }
            }
        }
    }

    func addCityToList(_ city: GeoLocation) {
        guard let viewState = viewState as? MainViewState else { return }
        
        if city.name == "My Location" {
            if let idx = viewState.savedCities.firstIndex(where: { $0.name == "My Location" }) {
                let existingLocation = viewState.savedCities[idx]
                // Check if coordinates are significantly different
                let distance = sqrt(pow(city.lat - existingLocation.lat, 2) + pow(city.lon - existingLocation.lon, 2))
                
                if distance > 0.000001 { // Only update if location changed significantly (more than ~10 centimeters)
                    var updatedCities = viewState.savedCities
                    updatedCities[idx] = city
                    viewState.updateSavedCities(updatedCities)
                }
            } else {
                var updatedCities = viewState.savedCities
                updatedCities.insert(city, at: 0)
                viewState.updateSavedCities(updatedCities)
            }
            return
        }
        
        if viewState.savedCities.contains(city) {
            return
        }
        
        var updatedCities = viewState.savedCities
        updatedCities.append(city)
        viewState.updateSavedCities(updatedCities)
        // Do not navigate automatically; left for user to tap from list
    }

    func removeCity(_ city: GeoLocation) {
        guard let viewState = viewState as? MainViewState else { return }
        var updatedCities = viewState.savedCities
        updatedCities.removeAll { $0 == city }
        viewState.updateSavedCities(updatedCities)
    }
    
    func isCityInSavedList(_ city: GeoLocation) -> Bool {
        guard let viewState = viewState as? MainViewState else { return false }
        return viewState.savedCities.contains(city)
    }
    
    func fetchWeatherFromText(_ text: String) {
        if let first = allCities.first(where: { $0.name.lowercased().contains(text.lowercased()) }) {
            selectCity(first)
        }
    }
    
    func fetchWeather(for coordinates: CLLocationCoordinate2D) {
        viewState?.updateLoading(true)
        
        Task {
            do {
                let weather = try await interactor.fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateWeather(weather)
                }
            } catch {
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateErrorMessage(error.localizedDescription)
                }
            }
        }
    }

    func fetchWeatherForLocationAndNavigate(_ coordinates: CLLocationCoordinate2D) {
        viewState?.updateLoading(true)
        
        Task {
            do {
                let weather = try await interactor.fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
                let city = GeoLocation(name: "My Location", lat: coordinates.latitude, lon: coordinates.longitude, country: "")
                
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateWeather(weather)
                    addCityToList(city)
                    router.showWeatherDetail(for: weather, city: city)
                }
            } catch {
                await MainActor.run {
                    viewState?.updateLoading(false)
                    viewState?.updateErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Data Persistence Methods
    func loadLastLocation() -> CLLocationCoordinate2D? {
        return interactor.loadLastLocation()
    }
    
    func persistLastLocation(_ coords: CLLocationCoordinate2D) {
        // Check if coordinates are significantly different from last saved location
        if let lastLocation = interactor.loadLastLocation() {
            let distance = sqrt(pow(coords.latitude - lastLocation.latitude, 2) + pow(coords.longitude - lastLocation.longitude, 2))
            // Only persist if location changed significantly (more than ~10 centimeters)
            guard distance > 0.000001 else { 
                return 
            }
        }
        
        interactor.persistLastLocation(coords)
    }
    
    func saveSavedCities(_ cities: [GeoLocation]) {
        interactor.saveSavedCities(cities)
    }
    
    func loadSavedCities() {
        let cities = interactor.loadSavedCities()
        DispatchQueue.main.async {
            self.viewState?.updateSavedCities(cities)
        }
    }
    
    // MARK: - Location Service Methods
    func requestLocationPermission() {
        interactor.requestLocationPermission()
    }
    
    func requestLocation() {
        interactor.requestLocation()
    }
    
    func setLocationCallback(_ callback: @escaping (CLLocationCoordinate2D?) -> Void) {
        interactor.setLocationCallback(callback)
    }
    
    func setPermissionGrantedCallback(_ callback: @escaping () -> Void) {
        interactor.setPermissionGrantedCallback(callback)
    }
    
    // MARK: - Location Callback Handling
    func handleLocationUpdate(_ coords: CLLocationCoordinate2D) {
        guard let viewState = viewState as? MainViewState else { return }
        
        guard viewState.shouldNavigateOnLocation else { return }
        guard !viewState.didNavigateFromLocation else { return }
        
        // Check if coordinates are significantly different from last saved location
        if let lastLocation = interactor.loadLastLocation() {
            let distance = sqrt(pow(coords.latitude - lastLocation.latitude, 2) + pow(coords.longitude - lastLocation.longitude, 2))
            // Only proceed if location changed significantly (more than ~10 centimeters)
            guard distance > 0.000001 else { return }
        }
        
        viewState.didNavigateFromLocation = true
        fetchWeatherForLocationAndNavigate(coords)
        addCityToList(GeoLocation(name: "My Location", lat: coords.latitude, lon: coords.longitude, country: ""))
        interactor.persistLastLocation(coords)
    }
    
    // MARK: - Navigation State Management
    func resetNavigationFlag() {
        if let viewState = viewState as? MainViewState {
            viewState.resetNavigationFlag()
        }
    }
}

