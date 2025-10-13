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
            // Создаем дефолтный город если city = nil
            let cityToUse = city ?? GeoLocation(name: "Unknown", lat: 0.0, lon: 0.0, country: "Unknown")
            nav.items.append(.weather(weather: weather, city: cityToUse))
        }
    }
}
