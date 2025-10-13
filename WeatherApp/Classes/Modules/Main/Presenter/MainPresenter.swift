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
    private var navigateOnNextFetch = false
    private var pendingCityForNavigation: GeoLocation?
    private var savedCities: [GeoLocation] = [] {
        didSet { viewState?.updateSavedCities(savedCities) }
    }
    
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
        
        // Set presenter reference in interactor
        if let interactor = interactor as? MainInteractor {
            interactor.presenter = self
        }
    }
    
    func onAppear() {
        // Do not auto-fetch weather on launch; show empty state with search and saved list
        viewState?.updateSavedCities(savedCities)
    }
    
    func updateSuggestions(for text: String) {
        guard !text.isEmpty else {
            viewState?.updateCitySuggestions([])
            return
        }
        print("🔍 Searching for city:", text)
        
        interactor.fetchCitySuggestions(for: text) { [weak self] result in
            switch result {
            case .success(let cities):
                print("🏙️ Suggestions:", cities.map { $0.name })
                self?.viewState?.updateCitySuggestions(cities)
            case .failure(let error):
                print("❌ Fetch error:", error)
                self?.viewState?.updateCitySuggestions([])
            }
        }
    }
    
    func selectCity(_ city: GeoLocation) {
        viewState?.updateLoading(true)
        navigateOnNextFetch = true
        pendingCityForNavigation = city
        if city.name == "My Location" {
            interactor.fetchWeather(lat: city.lat, lon: city.lon)
        } else {
            interactor.fetchWeather(for: city)
        }
        viewState?.updateCitySuggestions([])
    }

    func addCityToList(_ city: GeoLocation) {
        if city.name == "My Location" {
            if let idx = savedCities.firstIndex(where: { $0.name == "My Location" }) {
                // update coordinates of existing My Location entry
                savedCities[idx] = city
            } else {
                savedCities.insert(city, at: 0)
            }
            return
        }
        guard !savedCities.contains(city) else { return }
        savedCities.append(city)
        // Do not navigate automatically; left for user to tap from list
    }

    func removeCity(_ city: GeoLocation) {
        savedCities.removeAll { $0 == city }
    }
    
    func fetchWeatherFromText(_ text: String) {
        if let first = allCities.first(where: { $0.name.lowercased().contains(text.lowercased()) }) {
            selectCity(first)
        }
    }
    
    func fetchWeather(for coordinates: CLLocationCoordinate2D) {
        viewState?.updateLoading(true)
        interactor.fetchWeather(lat: coordinates.latitude, lon: coordinates.longitude)
    }

    func fetchWeatherForLocationAndNavigate(_ coordinates: CLLocationCoordinate2D) {
        navigateOnNextFetch = true
        pendingCityForNavigation = GeoLocation(name: "My Location", lat: coordinates.latitude, lon: coordinates.longitude, country: "")
        fetchWeather(for: coordinates)
    }
    
    func didFetchWeather(_ entity: WeatherEntity) {
        viewState?.updateLoading(false)
        viewState?.updateWeather(entity)
        if navigateOnNextFetch {
            navigateOnNextFetch = false
            // pass snapshot of saved cities for detail UI state (plus/checkmark)
            if let nav = (router as? MainRouter)?.navigation as? NavigationService {
                nav.savedCitiesSnapshot = savedCities
            }
            router.showWeatherDetail(for: entity, city: pendingCityForNavigation)
            pendingCityForNavigation = nil
        }
    }
    
    func didFail(with message: String) {
        viewState?.updateLoading(false)
        viewState?.updateErrorMessage(message)
    }
}
