//
//  WeatherDetailPresenter.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailPresenter: WeatherDetailPresenterProtocol {
    
    private let router: WeatherDetailRouterProtocol
    private weak var viewState: (any WeatherDetailViewStateProtocol)?
    private let interactor: WeatherDetailInteractorProtocol
    
    init(router: WeatherDetailRouterProtocol,
         interactor: WeatherDetailInteractorProtocol,
         viewState: any WeatherDetailViewStateProtocol) {
        self.router = router
        self.interactor = interactor
        self.viewState = viewState
    }
    
    func onAppear() {
        // Получаем данные из интерактора и обновляем ViewState
        if let weather = interactor.getWeather() {
            viewState?.updateWeather(weather)
        }
        
        if let city = interactor.getCity() {
            viewState?.updateCity(city)
            
            // Бизнес-логика: определяем, показывать ли кнопку добавления
            let shouldShowAddButton = city.name != "My Location" && !isCityInSavedList(city)
            viewState?.updateShowAddButton(shouldShowAddButton)
        }
    }
    
    private func isCityInSavedList(_ city: GeoLocation) -> Bool {
        // Проверяем через UserDefaults, есть ли город в списке
        if let data = UserDefaults.standard.data(forKey: "savedCities"),
           let cities = try? JSONDecoder().decode([GeoLocation].self, from: data) {
            return cities.contains(city)
        }
        return false
    }
    
    func addCityToList() {
        guard let city = interactor.getCity(),
              let added = viewState?.added,
              !added else { return }
        
        interactor.addCityToList(city)
        
        // Обновляем состояние после добавления
        viewState?.updateAdded(true)
    }
    
    func dismiss() {
        router.dismiss()
    }
}
