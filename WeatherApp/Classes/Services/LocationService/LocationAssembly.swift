//
//  LocationAssembly.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation

final class LocationAssembly: Assembly {
    
    func build() -> LocationServiceType {
        return LocationService()
    }
}
