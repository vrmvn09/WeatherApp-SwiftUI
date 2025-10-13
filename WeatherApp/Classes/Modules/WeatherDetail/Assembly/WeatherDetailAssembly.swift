//
//  WeatherDetailAssembly.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailAssembly: Assembly {
    
    func build() -> some View {
        let navigationService = container.resolve(NavigationAssembly.self).build() as! NavigationService
        
        let router = WeatherDetailRouter(navigationService: navigationService)
        let interactor = WeatherDetailInteractor()
        let viewState = WeatherDetailViewState()
        let presenter = WeatherDetailPresenter(
            router: router,
            interactor: interactor,
            viewState: viewState,
            navigationService: navigationService
        )
        
        viewState.set(with: presenter)
        
        // Передаем данные напрямую из NavigationService
        let weather = navigationService.currentWeather
        let city = navigationService.currentCity
        
        return WeatherDetailView(viewState: viewState, weather: weather, city: city, interactor: interactor)
    }
}
