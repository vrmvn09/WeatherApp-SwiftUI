//
//  WeatherDetailViewState.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailViewState: ObservableObject, WeatherDetailViewStateProtocol {
    
    @Published var weather: WeatherEntity?
    @Published var city: GeoLocation?
    @Published var isCityInList: Bool = false
    @Published var added: Bool = false
    @Published var hideAddButton: Bool = false
    
    private weak var presenterRef: WeatherDetailPresenterProtocol?
    
    var presenter: WeatherDetailPresenterProtocol? {
        return presenterRef
    }
    
    func set(with presenter: WeatherDetailPresenterProtocol) {
        self.presenterRef = presenter
    }
    
    func updateWeather(_ weather: WeatherEntity?) {
        self.weather = weather
    }
    
    func updateCity(_ city: GeoLocation?) {
        self.city = city
    }
    
    func updateIsCityInList(_ isInList: Bool) {
        self.isCityInList = isInList
    }
    
    func updateAdded(_ added: Bool) {
        self.added = added
    }
    
    func updateHideAddButton(_ hide: Bool) {
        self.hideAddButton = hide
    }
}
