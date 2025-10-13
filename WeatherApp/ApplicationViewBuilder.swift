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
        case .weather(let weather, let city):
            buildWeather(weather: weather, city: city)
        }
    }
    
    @ViewBuilder
    fileprivate func buildMain() -> some View {
        container.resolve(MainAssembly.self).build()
    }
    
    @ViewBuilder
    fileprivate func buildWeather(weather: WeatherEntity, city: GeoLocation) -> some View {
        container.resolve(WeatherDetailAssembly.self).build(weather: weather, city: city)
    }
    
}

extension ApplicationViewBuilder {
    
    static var stub: ApplicationViewBuilder {
        return ApplicationViewBuilder(
            container: RootApp().container
        )
    }
}
