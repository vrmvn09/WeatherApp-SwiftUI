//
//  WeatherDetailViewState.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailViewState: ObservableObject, WeatherDetailViewStateProtocol {
    
    @Published var weather: WeatherEntity?
    @Published var city: GeoLocation?
    @Published var showAddButton: Bool = false
    @Published var added: Bool = false
    
    var presenter: WeatherDetailPresenterProtocol?
    
    func set(with presenter: WeatherDetailPresenterProtocol) {
        self.presenter = presenter
    }
    
    // Computed properties для UI состояния
    var hasWeather: Bool {
        weather != nil
    }
    
    var weatherIcon: String {
        weather?.icon.systemIcon ?? "sun.max"
    }
    
    var weatherCity: String {
        weather?.city ?? "Unknown"
    }
    
    var weatherTemperature: String {
        weather != nil ? "\(Int(weather!.temperature))°C" : "0°C"
    }
    
    var weatherDescription: String {
        weather?.description.capitalized ?? "No data"
    }
    
    var weatherHumidity: Int {
        weather?.humidity ?? 0
    }
    
    var weatherWindSpeed: Double {
        weather?.windSpeed ?? 0
    }
    
    var weatherFeelsLike: Double {
        weather?.feelsLike ?? 0
    }
    
    var weatherPressure: Int {
        weather?.pressure ?? 0
    }
    
    var weatherSunrise: Date {
        weather?.sunrise ?? Date()
    }
    
    var weatherSunset: Date {
        weather?.sunset ?? Date()
    }
    
    var hasWeatherDetails: Bool {
        weatherHumidity != 0 || weatherWindSpeed != 0
    }
    
    // UI computed properties для кнопки
    var buttonIcon: String {
        added ? "checkmark.circle.fill" : "plus.circle.fill"
    }
    
    var buttonOpacity: Double {
        showAddButton ? 1.0 : 0.0
    }
    
    var buttonDisabled: Bool {
        !showAddButton
    }
    
    // UI computed property для фона
    var backgroundIcon: String {
        weather?.icon ?? "01d"
    }
    
    func updateWeather(_ weather: WeatherEntity?) {
        self.weather = weather
    }
    
    func updateCity(_ city: GeoLocation?) {
        self.city = city
    }
    
    func updateShowAddButton(_ show: Bool) {
        self.showAddButton = show
    }
    
    func updateAdded(_ added: Bool) {
        self.added = added
    }
    
    // MARK: - User Actions (delegate to presenter)
    func addCityToList() {
        presenter?.addCityToList()
    }
    
    func onAppear() {
        presenter?.onAppear()
    }
    
    func navigateBack() {
        presenter?.navigateBack()
    }
}
