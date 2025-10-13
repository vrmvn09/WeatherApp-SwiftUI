//
//  WeatherDetailAssembly.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailAssembly: Assembly {
    
    func build(weather: WeatherEntity, city: GeoLocation) -> some View {
        let navigationService = container.resolve(NavigationAssembly.self).build() as! NavigationService
        
        let router = WeatherDetailRouter(navigationService: navigationService)
        let interactor = WeatherDetailInteractor()
        let viewState = WeatherDetailViewState()
        let presenter = WeatherDetailPresenter(
            router: router,
            interactor: interactor,
            viewState: viewState
        )
        
        // Передаем данные в интерактор согласно документации
        interactor.setWeather(weather)
        interactor.setCity(city)
        
        return WeatherDetailView(viewState: viewState, presenter: presenter)
    }
}
