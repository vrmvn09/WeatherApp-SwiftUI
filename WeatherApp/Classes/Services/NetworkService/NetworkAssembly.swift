//
//  NetworkAssembly.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation

final class NetworkAssembly: Assembly {
    
    func build() -> NetworkServiceType {
        return NetworkService()
    }
}
