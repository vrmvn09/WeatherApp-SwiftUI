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
    private weak var navigationService: NavigationService?
    
    init(router: WeatherDetailRouterProtocol,
         interactor: WeatherDetailInteractorProtocol,
         viewState: any WeatherDetailViewStateProtocol,
         navigationService: NavigationService) {
        self.router = router
        self.interactor = interactor
        self.viewState = viewState
        self.navigationService = navigationService
        
        // Set presenter reference in interactor
        if let interactor = interactor as? WeatherDetailInteractor {
            interactor.presenter = self
        }
    }
    
    func onAppear() {
        // Получаем данные из NavigationService
        if let weather = navigationService?.currentWeather {
            viewState?.updateWeather(weather)
        }
        
        if let city = navigationService?.currentCity {
            viewState?.updateCity(city)
            // Используем значение из NavigationService вместо проверки через interactor
            let isInList = navigationService?.isCityInList ?? false
            print("📋 WeatherDetailPresenter: City '\(city.name)' isCityInList from NavigationService: \(isInList)")
            viewState?.updateIsCityInList(isInList)
        }
    }
    
    func addCityToList() {
        guard let city = viewState?.city,
              let added = viewState?.added,
              !added else { return }
        
        interactor.addCityToList(city)
        
        // Обновляем состояние UI
        viewState?.updateAdded(true)
        
        // Автоматически скрываем кнопку через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.viewState?.updateAdded(false)
            self.viewState?.updateHideAddButton(true)
        }
    }
    
    func dismiss() {
        router.dismiss()
    }
}
