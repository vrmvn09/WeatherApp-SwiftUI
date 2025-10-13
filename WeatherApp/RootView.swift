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
    let appViewBuilder: ApplicationViewBuilder
    
    var body: some View {
        NavigationStack(path: $navigationService.items) {
            appViewBuilder.build(view: .main)
                .navigationDestination(for: Views.self) { path in
                    appViewBuilder.build(view: path)
                }
        }
        .fullScreenCover(item: $navigationService.popupView) { item in
            appViewBuilder.build(view: item)
                .presentationBackground(.clear)
        }
        .fullScreenCover(item: $navigationService.modalView) { item in
            appViewBuilder.build(view: item)
        }
        .alert(isPresented: .constant($navigationService.alert.wrappedValue != nil)) {
            switch navigationService.alert {
            case .defaultAlert(let yesAction, let noAction):
                return Alert(title: Text("Title"),
                             primaryButton: .default(Text("Yes"), action: yesAction),
                             secondaryButton: .destructive(Text("No"), action: noAction))
            case .none:
                fatalError()
            }
        }
        
    }
}

// Notification name for adding city from detail
extension Notification.Name {
    static let addCityFromDetail = Notification.Name("addCityFromDetail")
}
