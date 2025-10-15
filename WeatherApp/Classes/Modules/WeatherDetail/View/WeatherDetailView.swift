//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Arman Urstem on 2025.
//

import SwiftUI

struct WeatherDetailView: View {
    @ObservedObject var viewState: WeatherDetailViewState
    
    init(viewState: WeatherDetailViewState) {
        self.viewState = viewState
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // Кнопка "Back"
                Button(action: {
                    viewState.navigateBack()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial.opacity(0.4))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                       // Кнопка добавления города
                       Button(action: {
                           viewState.addCityToList()
                       }) {
                           Image(systemName: viewState.buttonIcon)
                               .font(.system(size: 24, weight: .bold))
                               .foregroundColor(.white)
                               .padding(8)
                               .background(.ultraThinMaterial.opacity(0.3))
                               .clipShape(Circle())
                       }
                       .opacity(viewState.buttonOpacity)
                       .disabled(viewState.buttonDisabled)
            }
            .padding()
            
            Image(systemName: viewState.weatherIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .yellow)
                .shadow(color: .black.opacity(0.3), radius: 4)

            Text(viewState.weatherCity)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text(viewState.weatherTemperature)
                .font(.system(size: 54, weight: .light))
                .foregroundColor(.white)

            Text(viewState.weatherDescription)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))

            if viewState.hasWeatherDetails {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        WeatherInfoCard(icon: "thermometer.medium", title: "Feels like", value: "\(Int(viewState.weatherFeelsLike))°C", colorIcon: "red")
                        WeatherInfoCard(icon: "wind", title: "Wind", value: "\(String(format: "%.1f", viewState.weatherWindSpeed)) m/s", colorIcon: "")
                        WeatherInfoCard(icon: "humidity", title: "Humidity", value: "\(viewState.weatherHumidity)%", colorIcon: "")
                    }
                    HStack(spacing: 12) {
                        WeatherInfoCard(icon: "barometer", title: "Pressure", value: "\(viewState.weatherPressure) hPa", colorIcon: "")
                        SimpleTimeBox(title: "Sunrise", time: viewState.weatherSunrise, icon: "sunrise.fill", colorIcon: "yellow")
                        SimpleTimeBox(title: "Sunset", time: viewState.weatherSunset, icon: "sunset.fill", colorIcon: "orange")
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
                WeatherBackgroundView(icon: viewState.backgroundIcon)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
               .onAppear {
                   viewState.onAppear()
               }
    }
}

