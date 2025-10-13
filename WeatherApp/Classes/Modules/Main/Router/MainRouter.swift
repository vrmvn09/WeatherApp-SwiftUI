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
    
    init(navigation: any NavigationServiceType){
        self.navigation = navigation
    }
    
    func showWeatherDetail(for weather: WeatherEntity, city: GeoLocation?) {
        if let nav = navigation as? NavigationService {
            nav.selectedWeather = weather
            nav.selectedCityMeta = city
            if nav.items.last != .weather {
                nav.items.append(.weather)
            }
        }
    }
}
