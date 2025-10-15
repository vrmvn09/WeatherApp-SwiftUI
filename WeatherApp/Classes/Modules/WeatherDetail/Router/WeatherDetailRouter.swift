//
//  WeatherDetailRouter.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailRouter: WeatherDetailRouterProtocol {
    
    private weak var navigationService: (any NavigationServiceType)?
    
    init(navigationService: any NavigationServiceType) {
        self.navigationService = navigationService
    }
    
    func dismiss() {
        navigationService?.items.removeLast()
    }
    
    func navigateBack() {
        navigationService?.items.removeLast()
    }
    
    func navigateToRoot() {
        navigationService?.items.removeAll()
    }
    
    func showNetworkErrorAlert(retryAction: (() -> Void)?) {
        navigationService?.alert = .networkError(retryAction: retryAction)
    }
    
    func addCityToList(_ city: GeoLocation) {
        // Отправляем уведомление для добавления города в MainPresenter
        NotificationCenter.default.post(name: .addCityFromDetail, object: city)
    }
}
