//
//  WeatherDetailContracts.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

// MARK: - WeatherDetailViewStateProtocol
protocol WeatherDetailViewStateProtocol: ObservableObject {
    var weather: WeatherEntity? { get }
    var city: GeoLocation? { get }
    var isCityInList: Bool { get }
    var added: Bool { get }
    var hideAddButton: Bool { get }
    
    func updateWeather(_ weather: WeatherEntity?)
    func updateCity(_ city: GeoLocation?)
    func updateIsCityInList(_ isInList: Bool)
    func updateAdded(_ added: Bool)
    func updateHideAddButton(_ hide: Bool)
}

// MARK: - WeatherDetailPresenterProtocol
protocol WeatherDetailPresenterProtocol: AnyObject {
    func onAppear()
    func addCityToList()
    func dismiss()
}

// MARK: - WeatherDetailInteractorProtocol
protocol WeatherDetailInteractorProtocol: AnyObject {
    var presenter: WeatherDetailPresenterProtocol? { get set }
    func addCityToList(_ city: GeoLocation)
    func isCityInSavedList(_ city: GeoLocation) -> Bool
}

// MARK: - WeatherDetailRouterProtocol
protocol WeatherDetailRouterProtocol: AnyObject {
    func dismiss()
}
