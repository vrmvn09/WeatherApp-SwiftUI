//
//  RootApp.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI

@main
struct RootApp: App {
    
    let container: DependencyContainer = {
        let factory = AssemblyFactory()
        let container = DependencyContainer(assemblyFactory: factory)
                
        // Services
        container.apply(NavigationAssembly.self)
    
        // Modules
        container.apply(MainAssembly.self)
        container.apply(WeatherDetailAssembly.self)

        return container
    }()

    var body: some Scene {
        WindowGroup {
            RootView(
                navigationService: container.resolve(NavigationAssembly.self).build() as! NavigationService,
                appViewBuilder: ApplicationViewBuilder(container: container)
            )
        }
    }
}
