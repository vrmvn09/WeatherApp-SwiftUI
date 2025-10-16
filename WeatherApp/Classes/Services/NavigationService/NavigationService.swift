//
//  NavigationService.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//


import SwiftUI
import Foundation

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
