//
//  LocationServiceType.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceType: ObservableObject {
    var location: CLLocationCoordinate2D? { get }
    var locationPublisher: Published<CLLocationCoordinate2D?>.Publisher { get }
    
    func requestPermission()
    func requestLocation()
}
