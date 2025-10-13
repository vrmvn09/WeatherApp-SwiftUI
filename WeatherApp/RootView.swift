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
    @ObservedObject var appViewBuilder: ApplicationViewBuilder
    
    var body: some View {
        NavigationStack(path: $navigationService.items) {
            appViewBuilder.build(view: .main)
                .navigationDestination(for: Views.self) { path in
                    switch path {
                    case .weather:
                        if let weather = navigationService.selectedWeather {
                            // reuse MainView's detail layout without new files
                            let isSaved = {
                                if let list = navigationService.savedCitiesSnapshot,
                                   let meta = navigationService.selectedCityMeta {
                                    return list.contains(meta)
                                }
                                return false
                            }()
                            WeatherDetailInline(weather: weather,
                                                isSaved: isSaved,
                                                onAdd: {
                                                    if let city = navigationService.selectedCityMeta {
                                                        NotificationCenter.default.post(name: .addCityFromDetail, object: city)
                                                    }
                                                })
                        } else {
                            EmptyView()
                        }
                    default:
                        fatalError()
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

// Inline detail view reused as destination; no new files created
private struct WeatherDetailInline: View {
    let weather: WeatherEntity
    var isSaved: Bool = false
    var onAdd: (() -> Void)? = nil
    @State private var added = false
    @State private var hideAddButton = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                if !isSaved && !hideAddButton {
                    Button(action: {
                        guard !added else { return }
                        onAdd?()
                        withAnimation { added = true }
                        // Auto-hide checkmark after delay and then hide the button entirely
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                added = false
                                hideAddButton = true
                            }
                        }
                    }) {
                        Image(systemName: added ? "checkmark" : "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Базовый градиент для гарантии отсутствия черного экрана
                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
                
                // Анимированный фон погоды
                WeatherBackgroundView(icon: weather.icon)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
