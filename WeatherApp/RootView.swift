//
    //  RootView.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI
import Foundation

struct RootView: View {
    @ObservedObject var navigationService: NavigationService
    @ObservedObject var applicationViewBuilder: ApplicationViewBuilder
    
    var body: some View {
        NavigationStack(path: $navigationService.items) {
            applicationViewBuilder.build(view: .Main)
                .navigationDestination(for: Module.self) { module in
                    applicationViewBuilder.build(view: module)
                }
        }
        .fullScreenCover(item: $navigationService.popup) { module in
            applicationViewBuilder.build(view: module)
                .presentationBackground(.clear)
        }
        .fullScreenCover(item: $navigationService.fullScreen) { module in
            applicationViewBuilder.build(view: module)
        }
        .alert(item: $navigationService.alert) { alertType in
            buildAlert(for: alertType)
        }
    }
    
    private func buildAlert(for alertType: NavigationAlert) -> Alert {
        switch alertType {
        case .deleteConfirmation(let yesAction, let noAction):
            return Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete this item?"),
                primaryButton: .destructive(Text("Delete"), action: yesAction),
                secondaryButton: .cancel(Text("Cancel"), action: noAction)
            )
        case .networkError(let retryAction):
            return Alert(
                title: Text("Network Error"),
                message: Text("Please check your connection and try again."),
                primaryButton: .default(Text("Retry"), action: retryAction),
                secondaryButton: .cancel()
            )
        }
    }
}

// Notification name for adding city from detail
extension Notification.Name {
    static let addCityFromDetail = Notification.Name("addCityFromDetail")
}
