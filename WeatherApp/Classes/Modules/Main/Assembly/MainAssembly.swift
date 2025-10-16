//
//  MainAssembly.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//


import SwiftUI

final class MainAssembly: Assembly {
    
    func build() -> some View {
        
        let navigationService = container.resolve(NavigationAssembly.self).build()
        let locationService = container.resolve(LocationAssembly.self).build()

        // Router
        let router = MainRouter(navigationService: navigationService)

        // Interactor
        let weatherAPIService = container.resolve(WeatherAPIAssembly.self).build()
        let interactor = MainInteractor(weatherAPIService: weatherAPIService)

        //ViewState
        let viewState =  MainViewState(locationService: locationService)

        // Presenter
        let presenter = MainPresenter(router: router,
                                                           interactor: interactor,
                                                           viewState: viewState)
        
        viewState.set(with: presenter)
        
        // View
        let view = MainView(viewState: viewState)
        return view
    }
}
