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

// MARK: - Network Service
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ url: URL) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ Decode error:", error)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 Raw JSON:", jsonString)
            }
            throw error
        }
    }
}

// MARK: - OpenWeather API
enum OpenWeatherAPI {
    static let baseURL = "https://api.openweathermap.org"
    static let units = "metric"
    
    private static func apiKey() throws -> String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !key.isEmpty {
            return key
        }
        throw NetworkError.missingAPIKey
    }
    
    static func citySearch(for query: String, limit: Int = 5) throws -> URL {
        let key = try apiKey()
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        let urlString = "\(baseURL)/geo/1.0/direct?q=\(encoded)&limit=\(limit)&appid=\(key)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        return url
    }

    static func weather(for city: String) throws -> URL {
        let key = try apiKey()
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        guard let url = URL(string: "\(baseURL)/data/2.5/weather?q=\(encodedCity)&appid=\(key)&units=\(units)") else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    static func weather(lat: Double, lon: Double) throws -> URL {
        let key = try apiKey()
        guard let url = URL(string: "\(baseURL)/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(key)&units=\(units)") else {
            throw NetworkError.invalidURL
        }
        return url
    }
}

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
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
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
    
    @Published var modalView: Views?
    @Published var popupView: Views?
    @Published var items: [Views] = []
    @Published var alert: CustomAlert?
    @Published var selectedWeather: WeatherEntity?
    @Published var selectedCityMeta: GeoLocation?
    @Published var savedCitiesSnapshot: [GeoLocation]?
}


enum Views: Identifiable, Equatable, Hashable {

    var id: String { stringKey }

    static func == (lhs: Views, rhs: Views) -> Bool {
        lhs.stringKey == rhs.stringKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.stringKey)
    }
    
    case main
    case weather
    
    var stringKey: String {
        switch self {
        case .main:
            return "main"
        case .weather:
            return "weather"
        }
    }
}


enum CustomAlert: Equatable, Hashable {
    static func == (lhs: CustomAlert, rhs: CustomAlert) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .defaultAlert:
            hasher.combine("defaultAlert")
        }
    }
    
    case defaultAlert(yesAction: (()->Void)?, noAction: (()->Void)?)
}
