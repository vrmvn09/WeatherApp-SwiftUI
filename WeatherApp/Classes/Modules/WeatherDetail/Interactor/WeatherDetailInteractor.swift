//
//  WeatherDetailInteractor.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

final class WeatherDetailInteractor: WeatherDetailInteractorProtocol {
    
    // Данные хранятся в интеракторе
    private var weather: WeatherEntity?
    private var city: GeoLocation?
    
    init() {}
    
    // Методы для установки данных
    func setWeather(_ weather: WeatherEntity) {
        self.weather = weather
    }
    
    func setCity(_ city: GeoLocation) {
        self.city = city
    }
    
    // Методы для получения данных
    func getWeather() -> WeatherEntity? {
        return weather
    }
    
    func getCity() -> GeoLocation? {
        return city
    }
    
    func addCityToList(_ city: GeoLocation) {
        // Отправляем уведомление для добавления города в MainPresenter
        NotificationCenter.default.post(name: .addCityFromDetail, object: city)
    }
}
