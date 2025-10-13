//
//  MainContracts.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI
import CoreLocation

// Router
protocol MainRouterProtocol: RouterProtocol {
    func showWeatherDetail(for weather: WeatherEntity, city: GeoLocation?)
}

// Presenter
protocol MainPresenterProtocol: PresenterProtocol {
    func onAppear()
    func updateSuggestions(for text: String)
    func selectCity(_ city: GeoLocation)
    func addCityToList(_ city: GeoLocation)
    func removeCity(_ city: GeoLocation)
    func fetchWeatherFromText(_ text: String)
    func fetchWeather(for coordinates: CLLocationCoordinate2D)
    func fetchWeatherForLocationAndNavigate(_ coordinates: CLLocationCoordinate2D)
}

// Interactor
protocol MainInteractorProtocol: InteractorProtocol {
    func fetchCurrentWeather() async throws -> WeatherEntity
    func fetchWeather(for location: GeoLocation) async throws -> WeatherEntity
    func fetchWeather(for coordinates: CLLocationCoordinate2D) async throws -> WeatherEntity
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherEntity
    func fetchCitySuggestions(for query: String, completion: @escaping (Result<[GeoLocation], Error>) -> Void)
}

// ViewState
protocol MainViewStateProtocol: ViewStateProtocol {
    var citySuggestions: [GeoLocation] { get }
    func set(with presenter: MainPresenterProtocol)
    func updateWeather(_ weather: WeatherEntity)
    func updateLoading(_ isLoading: Bool)
    func updateErrorMessage(_ message: String?)
    func updateCitySuggestions(_ suggestions: [GeoLocation])
    func updateSavedCities(_ cities: [GeoLocation])
}
