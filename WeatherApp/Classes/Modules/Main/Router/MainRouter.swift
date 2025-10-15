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
        // Создаем дефолтный город если city = nil
        let cityToUse = city ?? GeoLocation(name: "Unknown", lat: 0.0, lon: 0.0, country: "Unknown")
        navigationService.items.append(.Weather(weather: weather, city: cityToUse))
    }
    
    // MARK: - Additional Navigation Methods
    func navigateToRoot() {
        navigationService.items.removeAll()
    }
    
    func showConfirmation(completed: (() -> Void)?) {
        // navigationService.fullScreen = .Confirmation(completed: completed)
        // Пока не реализовано, так как нет Confirmation модуля
    }
    
    func showDeleteAlert(onConfirm: (() -> Void)?, onCancel: (() -> Void)?) {
        navigationService.alert = .deleteConfirmation(yesAction: onConfirm, noAction: onCancel)
    }
}
