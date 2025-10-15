//
//  WeatherAPIAssembly.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

final class WeatherAPIAssembly: Assembly {
    
    func build() -> WeatherAPIServiceType {
        let networkService = container.resolve(NetworkAssembly.self).build()
        return WeatherAPIService(networkService: networkService)
    }
}
