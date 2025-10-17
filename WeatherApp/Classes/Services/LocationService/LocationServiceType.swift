//
//  LocationServiceType.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation
import CoreLocation

protocol LocationServiceType {
    var location: CLLocationCoordinate2D? { get }
    
    func requestPermission()
    func requestLocation()
    func setLocationCallback(_ callback: @escaping (CLLocationCoordinate2D?) -> Void)
    func setPermissionGrantedCallback(_ callback: @escaping () -> Void)
}
