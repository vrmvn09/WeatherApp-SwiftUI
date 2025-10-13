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

        // Router
        let router = MainRouter(navigationService: navigationService)

        // Interactor
        let interactor = MainInteractor(network: NetworkService())

        //ViewState
        let viewState =  MainViewState()

        // Presenter
        let presenter = MainPresenter(router: router,
                                                           interactor: interactor,
                                                           viewState: viewState)
        
        viewState.set(with: presenter)
        
        // View
        let view = MainView(viewState: viewState, presenter: presenter)
        return view
    }
}
