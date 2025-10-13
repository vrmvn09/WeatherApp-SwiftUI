//
//  WeatherDetailContracts.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

// MARK: - WeatherDetailViewStateProtocol
protocol WeatherDetailViewStateProtocol: ObservableObject {
    var weather: WeatherEntity? { get }
    var city: GeoLocation? { get }
    var showAddButton: Bool { get }
    var added: Bool { get }
    
    // Computed properties для UI состояния
    var hasWeather: Bool { get }
    var weatherIcon: String { get }
    var weatherCity: String { get }
    var weatherTemperature: String { get }
    var weatherDescription: String { get }
    var weatherHumidity: Int { get }
    var weatherWindSpeed: Double { get }
    var weatherFeelsLike: Double { get }
    var weatherPressure: Int { get }
    var weatherSunrise: Date { get }
    var weatherSunset: Date { get }
    var hasWeatherDetails: Bool { get }
    
    // UI computed properties для кнопки
    var buttonIcon: String { get }
    var buttonOpacity: Double { get }
    var buttonDisabled: Bool { get }
    
    // UI computed property для фона
    var backgroundIcon: String { get }
    
    func updateWeather(_ weather: WeatherEntity?)
    func updateCity(_ city: GeoLocation?)
    func updateShowAddButton(_ show: Bool)
    func updateAdded(_ added: Bool)
}

// MARK: - WeatherDetailPresenterProtocol
protocol WeatherDetailPresenterProtocol: AnyObject {
    func onAppear()
    func addCityToList()
    func dismiss()
}

// MARK: - WeatherDetailInteractorProtocol
protocol WeatherDetailInteractorProtocol: AnyObject {
    func setWeather(_ weather: WeatherEntity)
    func setCity(_ city: GeoLocation)
    func getWeather() -> WeatherEntity?
    func getCity() -> GeoLocation?
    func addCityToList(_ city: GeoLocation)
}

// MARK: - WeatherDetailRouterProtocol
protocol WeatherDetailRouterProtocol: AnyObject {
    func dismiss()
}
