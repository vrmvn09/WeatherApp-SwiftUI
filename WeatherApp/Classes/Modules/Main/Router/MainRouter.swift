//
//  MainRouter.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation

final class MainRouter: MainRouterProtocol {
    var navigationService: any NavigationServiceType
    
    init(navigationService: any NavigationServiceType){
        self.navigationService = navigationService
    }
    
    func showWeatherDetail(for weather: WeatherEntity, city: GeoLocation?) {
        if let nav = navigationService as? NavigationService {
            // Создаем дефолтный город если city = nil
            let cityToUse = city ?? GeoLocation(name: "Unknown", lat: 0.0, lon: 0.0, country: "Unknown")
            nav.items.append(.Weather(weather: weather, city: cityToUse))
        }
    }
}
