//
//  WeatherDetailContracts.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

// MARK: - WeatherDetailViewStateProtocol
protocol WeatherDetailViewStateProtocol: ViewStateProtocol {
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
protocol WeatherDetailPresenterProtocol: PresenterProtocol {
    func onAppear()
    func addCityToList()
    func dismiss()
    func navigateBack()
}

// MARK: - WeatherDetailInteractorProtocol
protocol WeatherDetailInteractorProtocol: InteractorProtocol {
    func setWeather(_ weather: WeatherEntity)
    func setCity(_ city: GeoLocation)
    func getWeather() -> WeatherEntity?
    func getCity() -> GeoLocation?
    func addCityToList(_ city: GeoLocation)
}

// MARK: - WeatherDetailRouterProtocol
protocol WeatherDetailRouterProtocol: RouterProtocol {
    func dismiss()
    func navigateBack()
    func navigateToRoot()
    func showNetworkErrorAlert(retryAction: (() -> Void)?)
    func addCityToList(_ city: GeoLocation)
}
