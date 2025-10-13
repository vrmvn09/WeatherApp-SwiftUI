//
//  ApplicationViewBuilder.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI

final class ApplicationViewBuilder {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
   
    @ViewBuilder
    func build(view: Views) -> some View {
        switch view {
        case .main:
            buildMain()
        case .weather:
            buildWeather()
        }
    }
    
    @ViewBuilder
    fileprivate func buildMain() -> some View {
        container.resolve(MainAssembly.self).build()
    }
    
    @ViewBuilder
    fileprivate func buildWeather() -> some View {
        WeatherDetailView(navigationService: container.resolve(NavigationAssembly.self).build() as! NavigationService)
    }
    
}

extension ApplicationViewBuilder {
    
    static var stub: ApplicationViewBuilder {
        return ApplicationViewBuilder(
            container: RootApp().container
        )
    }
}
