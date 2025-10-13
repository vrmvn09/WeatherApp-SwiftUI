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
                    switch path {
                    case .weather:
                        WeatherDetailView(navigationService: navigationService)
                    default:
                        EmptyView()
                    }
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

// Simple Weather Detail View
struct WeatherDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var navigationService: NavigationService
    @State private var added = false
    @State private var hideAddButton = false
    
    init(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(.white)
                Spacer()
                
                // Кнопка добавления города (только для обычных городов, не для геолокации и не для уже сохраненных)
                if let city = navigationService.currentCity, 
                   city.name != "My Location" && 
                   !navigationService.isCityInList && 
                   !hideAddButton {
                    Button(action: {
                        guard !added else { return }
                        // Используем callback для добавления города
                        navigationService.onAddCity?(city)
                        print("🔔 Called onAddCity callback for: \(city.name)")
                        withAnimation { added = true }
                        // Автоматически скрываем кнопку через 2 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                added = false
                                hideAddButton = true
                            }
                        }
                    }) {
                        Image(systemName: added ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            
            if let weather = navigationService.currentWeather {
                Image(systemName: weather.icon.systemIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .yellow)
                    .shadow(color: .black.opacity(0.3), radius: 4)

                Text(weather.city)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("\(Int(weather.temperature))°C")
                    .font(.system(size: 54, weight: .light))
                    .foregroundColor(.white)

                Text(weather.description.capitalized)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                if weather.humidity != 0 || weather.windSpeed != 0 {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            WeatherInfoCard(icon: "thermometer.medium", title: "Feels like", value: "\(Int(weather.feelsLike))°C", colorIcon: "red")
                            WeatherInfoCard(icon: "wind", title: "Wind", value: "\(String(format: "%.1f", weather.windSpeed)) m/s", colorIcon: "")
                            WeatherInfoCard(icon: "humidity", title: "Humidity", value: "\(weather.humidity)%", colorIcon: "")
                        }
                        HStack(spacing: 12) {
                            WeatherInfoCard(icon: "barometer", title: "Pressure", value: "\(weather.pressure) hPa", colorIcon: "")
                            SimpleTimeBox(title: "Sunrise", time: weather.sunrise, icon: "sunrise.fill", colorIcon: "yellow")
                            SimpleTimeBox(title: "Sunset", time: weather.sunset, icon: "sunset.fill", colorIcon: "orange")
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }
            } else {
                Text("Weather Details")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("No weather data available")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Базовый градиент для гарантии отсутствия черного экрана
                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
                
                // Анимированный фон погоды
                if let weather = navigationService.currentWeather {
                    WeatherBackgroundView(icon: weather.icon)
                }
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
