//
//  MainViewState.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI

final class MainViewState: ObservableObject, MainViewStateProtocol {    
    private let id = UUID()
    private var presenter: MainPresenterProtocol?
    
    func set(with presener: MainPresenterProtocol) {
        self.presenter = presener
    }
}
