//
//  ApplicationViewBuilder.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI

final class ApplicationViewBuilder: Assembly, ObservableObject {
    
    required init(container: Container) {
        super.init(container: container)
    }
   
    @ViewBuilder
    func build(view: Views) -> some View {
        switch view {
        case .main:
            buildMainModule()
        case .weather(let weather, let city):
            buildWeatherModule(weather: weather, city: city)
        }
    }
    
    // Private builder methods
    @ViewBuilder
    private func buildMainModule() -> some View {
        container.resolve(MainAssembly.self).build()
    }
    
    @ViewBuilder
    private func buildWeatherModule(weather: WeatherEntity, city: GeoLocation) -> some View {
        container.resolve(WeatherDetailAssembly.self).build(weather: weather, city: city)
    }
    
}
