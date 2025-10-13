//
//  MainRouter.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation

final class MainRouter: MainRouterProtocol {
    var navigation: any NavigationServiceType
    private weak var presenter: MainPresenterProtocol?
    
    init(navigation: any NavigationServiceType){
        self.navigation = navigation
    }
    
    func setPresenter(_ presenter: MainPresenterProtocol) {
        self.presenter = presenter
    }
    
    func showWeatherDetail(for weather: WeatherEntity, city: GeoLocation?) {
        if let nav = navigation as? NavigationService {
            nav.currentWeather = weather
            nav.currentCity = city
            
            // Устанавливаем callback для добавления города
            nav.onAddCity = { [weak self] city in
                self?.presenter?.addCityToList(city)
            }
            // Проверяем, есть ли город в списке
            if let city = city, let presenter = presenter as? MainPresenter {
                nav.isCityInList = presenter.isCityInSavedList(city)
            } else {
                nav.isCityInList = false
            }
            nav.items.append(.weather)
        }
    }
}
