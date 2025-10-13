//
//  WeatherDetailRouter.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import Foundation
import SwiftUI

final class WeatherDetailRouter: WeatherDetailRouterProtocol {
    
    private weak var navigationService: NavigationService?
    
    init(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func dismiss() {
        navigationService?.items.removeLast()
    }
}
