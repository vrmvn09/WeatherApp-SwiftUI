//
//  WeatherDetailInteractor.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

final class WeatherDetailInteractor: WeatherDetailInteractorProtocol {
    
    weak var presenter: WeatherDetailPresenterProtocol?
    
    init() {}
    
    func addCityToList(_ city: GeoLocation) {
        // Отправляем уведомление для добавления города в MainPresenter
        NotificationCenter.default.post(name: .addCityFromDetail, object: city)
    }
    
    func isCityInSavedList(_ city: GeoLocation) -> Bool {
        // Проверяем через UserDefaults, есть ли город в списке
        if let data = UserDefaults.standard.data(forKey: "savedCities"),
           let cities = try? JSONDecoder().decode([GeoLocation].self, from: data) {
            return cities.contains(city)
        }
        return false
    }
}
