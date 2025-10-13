//
//  NavigationServiceType.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import Foundation

/// The `NavigationServiceType` protocol defines a navigation service in the application,
/// providing management of the view stack, modal windows, popups, and alerts.
protocol NavigationServiceType: ObservableObject, Identifiable {
    
    /// An array of modules that make up the current navigation stack.
    /// Used for managing transitions between screens.
    /// By default, this array is empty, and the root page is bound to the NavigationStack body in the RootView body.
    var items: [Module] { get set }
    
    /// The current full screen module, if active.
    /// Can be `nil` if there is no active full screen presentation.
    var fullScreen: Module? { get set }
    
    /// The current popup module, if active.
    /// Can be `nil` if no popup is displayed.
    var popup: Module? { get set }
    
    /// The current alert (dialog window), if active.
    /// Can be `nil` if there are no active alerts.
    var alert: NavigationAlert? { get set }
}
