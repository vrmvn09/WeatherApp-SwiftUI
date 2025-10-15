//
//  NavigationService.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//


import SwiftUI
import Foundation
import CoreLocation

// MARK: - Location Manager
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        // Проверяем статус авторизации перед запросом
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func requestPermission() {
        print("LocationManager: requestPermission status=\(manager.authorizationStatus.rawValue)")
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            // Optionally open app settings
            print("LocationManager: denied/restricted, opening settings")
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } else {
            print("LocationManager: authorized, requesting location")
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        if let coord = location {
            NotificationCenter.default.post(name: .locationUpdated, object: coord)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location:", error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            NotificationCenter.default.post(name: .locationAuthorized, object: nil)
        case .denied, .restricted:
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

extension Notification.Name {
    static let locationAuthorized = Notification.Name("locationAuthorized")
    static let locationUpdated = Notification.Name("locationUpdated")
}

public class NavigationService: NavigationServiceType  {
    
    public let id = UUID()
    
    public static func == (lhs: NavigationService, rhs: NavigationService) -> Bool {
        lhs.id == rhs.id
    }
    
    @Published var fullScreen: Module?
    @Published var popup: Module?
    @Published var items: [Module] = []
    @Published var alert: NavigationAlert?
    
}


enum Module: Identifiable, Equatable, Hashable {

    var id: String { stringKey }

    static func == (lhs: Module, rhs: Module) -> Bool {
        lhs.stringKey == rhs.stringKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.stringKey)
    }
    
    case Main
    case Weather(weather: WeatherEntity, city: GeoLocation)
    
    var stringKey: String {
        switch self {
        case .Main:
            return "Main"
        case .Weather(let weather, let city):
            return "Weather-\(weather.city)-\(city.name)"
        }
    }
}


enum NavigationAlert: Identifiable, Equatable, Hashable {
    var id: Int { hashValue }
    
    static func == (lhs: NavigationAlert, rhs: NavigationAlert) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .deleteConfirmation:
            hasher.combine("deleteConfirmation")
        case .networkError:
            hasher.combine("networkError")
        }
    }
    
    case deleteConfirmation(yesAction: (() -> Void)?, noAction: (() -> Void)?)
    case networkError(retryAction: (() -> Void)?)
}
