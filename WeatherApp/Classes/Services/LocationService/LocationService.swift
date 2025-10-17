//
//  LocationService.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation
import CoreLocation

final class LocationService: NSObject, LocationServiceType {
    private let locationManager = CLLocationManager()
    private var locationCallback: ((CLLocationCoordinate2D?) -> Void)?
    private var permissionGrantedCallback: (() -> Void)?
    
    var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        let currentStatus = locationManager.authorizationStatus
        
        guard currentStatus != .denied else {
            return
        }
        
        guard currentStatus != .restricted else {
            return
        }
        
        if currentStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.requestLocation()
    }
    
    func setLocationCallback(_ callback: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.locationCallback = callback
    }
    
    func setPermissionGrantedCallback(_ callback: @escaping () -> Void) {
        self.permissionGrantedCallback = callback
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location.coordinate
        locationCallback?(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                break
            case .denied:
                break
            case .network:
                break
            case .headingFailure:
                break
            case .regionMonitoringDenied:
                break
            case .regionMonitoringFailure:
                break
            case .regionMonitoringSetupDelayed:
                break
            case .regionMonitoringResponseDelayed:
                break
            case .geocodeFoundNoResult:
                break
            case .geocodeFoundPartialResult:
                break
            case .geocodeCanceled:
                break
            default:
                break
            }
        }
        locationCallback?(nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionGrantedCallback?()
            requestLocation()
        case .denied:
            break
        case .restricted:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}