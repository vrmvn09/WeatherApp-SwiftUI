//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import SwiftUI

struct WeatherDetailView: View {
    @StateObject var viewState: WeatherDetailViewState
    let weather: WeatherEntity?
    let city: GeoLocation?
    let interactor: WeatherDetailInteractor
    
    init(viewState: WeatherDetailViewState, weather: WeatherEntity? = nil, city: GeoLocation? = nil, interactor: WeatherDetailInteractor) {
        self._viewState = StateObject(wrappedValue: viewState)
        self.weather = weather
        self.city = city
        self.interactor = interactor
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                // Кнопка добавления города (только для обычных городов, не для геолокации и не для уже сохраненных)
                if let city = viewState.city,
                   city.name != "My Location" &&
                   !viewState.isCityInList &&
                   !viewState.hideAddButton {
                    Button(action: {
                        // Используем interactor напрямую если presenter недоступен
                        if viewState.presenter != nil {
                            viewState.presenter?.addCityToList()
                        } else {
                            interactor.addCityToList(city)
                            // Обновляем UI состояние
                            viewState.updateAdded(true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                viewState.updateAdded(false)
                                viewState.updateHideAddButton(true)
                            }
                        }
                    }) {
                        Image(systemName: viewState.added ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial.opacity(0.3))
                            .clipShape(Circle())
                    }
                } else {
                    // Кнопка не показывается - отладочная информация в консоли
                    EmptyView()
                        .onAppear {
                            if let city = viewState.city {
                                print("🚫 WeatherDetailView: Plus button NOT showing for city: \(city.name)")
                                print("🚫 Reason: name='My Location'? \(city.name == "My Location")")
                                print("🚫 Reason: isCityInList? \(viewState.isCityInList)")
                                print("🚫 Reason: hideAddButton? \(viewState.hideAddButton)")
                            } else {
                                print("🚫 WeatherDetailView: Plus button NOT showing - no city data")
                            }
                        }
                }
            }
            .padding()
            
            if let weather = viewState.weather {
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
                if let weather = viewState.weather {
                    WeatherBackgroundView(icon: weather.icon)
                }
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            // Используем прямые параметры для установки данных
            if let weather = weather {
                viewState.updateWeather(weather)
            }
            if let city = city {
                viewState.updateCity(city)
                // Определяем, есть ли город в списке, используя interactor
                let isInList = interactor.isCityInSavedList(city)
                viewState.updateIsCityInList(isInList)
            }
        }
    }
}

