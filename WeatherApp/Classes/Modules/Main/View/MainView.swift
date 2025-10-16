//
//  MainView.swift
//  WeatherApp
//
//  Created by Arman on 11.10.2025
//  
//

import SwiftUI
import CoreLocation

struct MainView: View {
    @ObservedObject var viewState: MainViewState
    
    var body: some View {
        ZStack {
            // Background (static on main screen)
            LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        HStack(alignment: .center) {
                            Text("Weather")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                            Spacer()
                            Button(action: {
                                // Request location when user taps the button
                                viewState.shouldNavigateOnLocation = true
                                // Always request permission first, then location
                                viewState.requestLocationPermission()
                                // Also try to request location directly
                                viewState.requestLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 8)
                            Button(action: { withAnimation { viewState.isEditing.toggle() } }) {
                                Image(systemName: viewState.isEditing ? "checkmark" : "ellipsis.circle")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                        // No city subtitle on the main list page
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // MARK: - Search Bar
                    // MARK: - Modern Search Bar
                    ModernSearchBar(text: $viewState.searchText) {
                        viewState.fetchWeatherFromText(viewState.searchText)
                        viewState.searchText = ""
                    }
                    .onChange(of: viewState.searchText) { newValue in
                        viewState.updateSuggestions(for: newValue)
                    }

                    
                    // City suggestions will be positioned absolutely
                    
                    // MARK: - Saved Cities List
                    if !viewState.savedCities.isEmpty {
                        List {
                            ForEach(viewState.savedCities, id: \.id) { city in
                                let isMyLocation = city.name == "My Location"
                                HStack(spacing: 12) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                        .shadow(color: .black.opacity(0.4), radius: 2)

                                    Text(city.country.isEmpty ? city.name : "\(city.name), \(city.country)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.4), radius: 2)

                                    Spacer()

                                    if viewState.isEditing {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(isMyLocation ? .gray : .red)
                                            .font(.system(size: 18, weight: .bold))
                                            .onTapGesture { if !isMyLocation { viewState.removeCity(city) } }
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { viewState.selectCity(city) }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                        .padding(.vertical, 4)
                                )
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if !isMyLocation {
                                        Button(role: .destructive) {
                                            viewState.removeCity(city)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .scrollDisabled(true)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .background(Color.clear)
                    }

                    // MARK: - Weather Content (Static - never moves)
                    Spacer()
                    
                    if viewState.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.white)
                            Text("Loading...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                        .transition(.opacity)
                    } else if let error = viewState.errorMessage {
                        Text(error)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.7))
                            )
                            .padding()
                    } else if viewState.weather != nil {
                        // Показываем информацию о погоде, если она доступна
                        Text("Данные погоды загружены")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    
                    Spacer()
                }
                
                // MARK: - City Suggestions Overlay (Positioned correctly with keyboard)
                if !viewState.citySuggestions.isEmpty {
                    VStack {
                        // Position suggestions right after search bar
                        Spacer()
                            .frame(height: 130) // slightly tighter so first suggestion sits under search
                        
                        CitySuggestionsView(
                            suggestions: viewState.citySuggestions,
                            saved: viewState.savedCities,
                            onSelect: { location in
                                viewState.selectCity(location)
                                viewState.searchText = ""
                            },
                            onAdd: { location in
                                viewState.addCityToList(location)
                                // hide suggestions after adding
                                viewState.updateSuggestions(for: "")
                                viewState.searchText = ""
                            }
                        )
                        .frame(maxHeight: viewState.keyboardHeight > 0 ? 200 : 300) // Limit height when keyboard is visible
                        
                        Spacer()
                    }
                    .padding(.bottom, viewState.keyboardHeight > 0 ? viewState.keyboardHeight - 100 : 0) // Adjust for keyboard
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewState.citySuggestions.isEmpty)
                }
                }
                .onAppear {
                    viewState.onAppear()
                    // Only request permission on launch, not location
                    viewState.requestLocationPermission()
                    viewState.shouldNavigateOnLocation = true
                }
                // On first location update, fetch and navigate + auto-add to list
                .onReceive(viewState.locationPublisher) { coords in
                    guard let coords = coords else { 
                        return 
                    }
                    guard viewState.shouldNavigateOnLocation else { 
                        return 
                    }
                    guard !viewState.didNavigateFromLocation else { 
                        return 
                    }
                    
                    // Check if coordinates are significantly different from last saved location
                    if let lastLocation = viewState.loadLastLocation() {
                        let distance = sqrt(pow(coords.latitude - lastLocation.latitude, 2) + pow(coords.longitude - lastLocation.longitude, 2))
                        // Only proceed if location changed significantly (more than ~10 centimeters)
                        guard distance > 0.000001 else { 
                            return 
                        }
                    }
                    
                    viewState.didNavigateFromLocation = true
                    viewState.fetchWeatherForLocationAndNavigate(coords)
                    viewState.addCityToList(GeoLocation(name: "My Location", lat: coords.latitude, lon: coords.longitude, country: ""))
                    viewState.persistLastLocation(coords)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        viewState.keyboardHeight = keyboardFrame.height
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    viewState.keyboardHeight = 0
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
                .onReceive(NotificationCenter.default.publisher(for: .addCityFromDetail)) { output in
                    if let city = output.object as? GeoLocation {
                        viewState.addCityToList(city)
                    }
                }
            }
    }

// MARK: - Extensions
extension String {
    var systemIcon: String {
        switch self {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}



// MARK: - CitySuggestionsView with better contrast and scrolling
struct CitySuggestionsView: View {
    let suggestions: [GeoLocation]
    let saved: [GeoLocation]
    let onSelect: (GeoLocation) -> Void
    let onAdd: (GeoLocation) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(suggestions, id: \.id) { city in
                    Button {
                        onSelect(city)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .shadow(color: .black.opacity(0.4), radius: 2)
                            
                            Text("\(city.name), \(city.country)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 2)
                            
                            Spacer()
                            if !saved.contains(city) {
                                Button(action: { onAdd(city) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.white.opacity(0.85))
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    if city.id != suggestions.last?.id {
                        Divider()
                            .background(.white.opacity(0.2))
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .frame(
            minHeight: 120,
            maxHeight: 240
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
        .animation(.easeInOut, value: suggestions.count)
    }
}

struct WeatherInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let colorIcon: String
    
    private var resolvedColor: Color {
            switch colorIcon.lowercased() {
            case "red": return .red
            case "yellow": return .yellow
            case "green": return .green
            case "purple": return .purple
            case "orange": return .orange
            case "blue": return .blue
            case "cyan": return .cyan
            default: return .blue // Цвет по умолчанию для градиента, если строка пуста или неизвестна
            }
        }

    
    var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        colorIcon.isEmpty || (colorIcon.lowercased() == "blue" || colorIcon.lowercased() == "cyan")
                            ? AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(resolvedColor) // <-- Теперь использует resolvedColor
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white) // читаемый на белом фоне
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial) // полностью непрозрачный белый фон
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}


// MARK: - Simple Time Box
struct SimpleTimeBox: View {
    let title: String
    let time: Date
    let icon: String
    let colorIcon: String
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    private var resolvedColor: Color {
            switch colorIcon.lowercased() {
            case "red": return .red
            case "yellow": return .yellow
            case "green": return .green
            case "purple": return .purple // Для sunset.fill
            case "orange": return .orange // Для sunrise.fill
            case "blue": return .blue
            case "cyan": return .cyan
            default: return .blue
            }
        }
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        colorIcon.isEmpty || (colorIcon.lowercased() == "blue" || colorIcon.lowercased() == "cyan")
                            ? AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(resolvedColor) // <-- Теперь использует resolvedColor
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

            
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white) // читаемый на белом фоне
                .multilineTextAlignment(.center)

            Text(timeFormatter.string(from: time))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Modern Search Bar
struct ModernSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var onSubmit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 12)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Search city")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 17, weight: .medium))
                        .padding(.leading, 4)
                        .transition(.opacity)
                }
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .medium))
                    .focused($isFocused)
                    .onSubmit {
                        onSubmit()
                        isFocused = false
                    }
            }

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 12)
                        .transition(.scale)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(isFocused ? 0.6 : 0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}



// MARK: - Weather Background Animation
struct WeatherBackgroundAnimation: View {
    let weatherIcon: String
    @State private var rainDrops: [RainDrop] = []
    @State private var snowFlakes: [SnowFlake] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            // Rain animation
            if shouldShowRain {
                ForEach(rainDrops, id: \.id) { drop in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5, height: drop.length)
                        .position(x: drop.x, y: drop.y)
                        .opacity(drop.opacity)
                }
            }
            
            // Snow animation
            if shouldShowSnow {
                ForEach(snowFlakes, id: \.id) { flake in
                    Circle()
                        .fill(.white.opacity(flake.opacity))
                        .frame(width: flake.size, height: flake.size)
                        .position(x: flake.x, y: flake.y)
                        .rotationEffect(.degrees(flake.rotation))
                }
            }
            
        }
        .onAppear {
            startWeatherAnimation()
        }
        .onDisappear {
            stopWeatherAnimation()
        }
    }
    
    private var shouldShowRain: Bool {
        let rainKeywords = ["rain", "drizzle", "shower", "storm", "thunder"]
        return rainKeywords.contains { weatherIcon.lowercased().contains($0) }
    }
    
    private var shouldShowSnow: Bool {
        let snowKeywords = ["snow", "sleet", "blizzard"]
        return snowKeywords.contains { weatherIcon.lowercased().contains($0) }
    }
    
    
    private func startWeatherAnimation() {
        if shouldShowRain {
            generateRainDrops()
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                updateRainDrops()
            }
        } else if shouldShowSnow {
            generateSnowFlakes()
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                updateSnowFlakes()
            }
        }
    }
    
    private func stopWeatherAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    
    private func generateRainDrops() {
        rainDrops = (0..<60).map { _ in
            RainDrop(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...0),
                length: CGFloat.random(in: 15...35),
                speed: CGFloat.random(in: 3...7),
                opacity: Double.random(in: 0.4...0.9)
            )
        }
    }
    
    private func updateRainDrops() {
        for i in rainDrops.indices {
            rainDrops[i].y += rainDrops[i].speed
            if rainDrops[i].y > UIScreen.main.bounds.height + 50 {
                rainDrops[i].y = -50
                rainDrops[i].x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            }
        }
    }
    
    private func generateSnowFlakes() {
        snowFlakes = (0..<40).map { _ in
            SnowFlake(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...0),
                size: CGFloat.random(in: 3...8),
                speed: CGFloat.random(in: 0.8...2.5),
                opacity: Double.random(in: 0.5...0.9),
                rotation: Double.random(in: 0...360)
            )
        }
    }
    
    private func updateSnowFlakes() {
        for i in snowFlakes.indices {
            snowFlakes[i].y += snowFlakes[i].speed
            snowFlakes[i].x += CGFloat.random(in: -0.8...0.8)
            snowFlakes[i].rotation += 1.5
            
            if snowFlakes[i].y > UIScreen.main.bounds.height + 50 {
                snowFlakes[i].y = -50
                snowFlakes[i].x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            }
        }
    }
}


// MARK: - Weather Data Models
struct RainDrop {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let length: CGFloat
    let speed: CGFloat
    let opacity: Double
}

struct SnowFlake {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let opacity: Double
    var rotation: Double
}

// MARK: - WeatherBackgroundView
struct WeatherBackgroundView: View {
    let icon: String
    
    var body: some View {
        ZStack {
            // Базовый градиент только для ясной погоды
            if icon.contains("01") {
                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
            }
            
            // Специфичный градиент для погоды (всегда показываем)
            gradient
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 1.0), value: icon)
            
            // Weather animation overlay
            WeatherBackgroundAnimation(weatherIcon: icon)
            
            // Moon effect (for night)
            if icon.contains("n") {
                MoonGlowView()
                    .blendMode(.screen)
                    .transition(.opacity)
            }

            // Weather effects
            switch icon {
            case "01d", "01n":
                EmptyView() // clear
            case "02d", "03d", "04d":
                CloudsLayer()
            case "02n", "03n", "04n":
                CloudsLayer(isNight: true)
            case "09d", "10d":
                RainLayer()
            case "09n", "10n":
                RainLayer(isNight: true)
            case "13d":
                SnowLayer()
            case "13n":
                SnowLayer(isNight: true)
            case "50d":
                FogLayer()
            case "50n":
                FogLayer(isNight: true)
            case "11d", "11n":
                ThunderstormLayer()
            default:
                EmptyView()
            }
        }
    }

    // Day and night gradients
    private var gradient: LinearGradient {
        switch icon {
        case "01d": return LinearGradient(colors: [.blue.opacity(0.8), .cyan.opacity(0.6)],
                                          startPoint: .top, endPoint: .bottom)
        case "01n": return LinearGradient(colors: [.indigo.opacity(0.8), .black.opacity(0.9)],
                                          startPoint: .top, endPoint: .bottom)
        case "02d", "03d", "04d": return LinearGradient(colors: [.gray.opacity(0.9), .gray.opacity(0.95)],
                                                        startPoint: .top, endPoint: .bottom)
        case "02n", "03n", "04n": return LinearGradient(colors: [.gray.opacity(0.95), .black.opacity(0.98)],
                                                        startPoint: .top, endPoint: .bottom)
        case "09d", "10d": return LinearGradient(colors: [.gray.opacity(0.95), .gray.opacity(0.9)],
                                                 startPoint: .top, endPoint: .bottom)
        case "09n", "10n": return LinearGradient(colors: [.gray.opacity(0.95), .black.opacity(0.95)],
                                                 startPoint: .top, endPoint: .bottom)
        case "13d": return LinearGradient(colors: [.gray.opacity(0.9), .gray.opacity(0.95)],
                                          startPoint: .top, endPoint: .bottom)
        case "13n": return LinearGradient(colors: [.gray.opacity(0.95), .black.opacity(0.98)],
                                          startPoint: .top, endPoint: .bottom)
        case "50d": return LinearGradient(colors: [.gray.opacity(0.9), .gray.opacity(0.85)],
                                          startPoint: .top, endPoint: .bottom)
        case "50n": return LinearGradient(colors: [.gray.opacity(0.95), .black.opacity(0.95)],
                                          startPoint: .top, endPoint: .bottom)
        default: return LinearGradient(colors: [.blue.opacity(0.7), .cyan.opacity(0.5)],
                                       startPoint: .top, endPoint: .bottom)
        }
    }
}

struct CloudsLayer: View {
    var isNight: Bool = false
    @State private var move = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<3) { i in
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 140))
                        .foregroundColor(isNight ? .white.opacity(0.4) : .white.opacity(0.7))
                        .offset(x: move ? geo.size.width : -geo.size.width,
                                y: CGFloat(i * 80) - 100)
                        .animation(.linear(duration: 45)
                            .repeatForever(autoreverses: false), value: move)
                }
            }
            .onAppear { move = true }
        }
    }
}

struct FogLayer: View {
    var isNight: Bool = false
    @State private var shift = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<2) { i in
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(colors: [
                                .white.opacity(isNight ? 0.08 : 0.15),
                                .gray.opacity(isNight ? 0.2 : 0.1)
                            ], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.5)
                        .blur(radius: 60)
                        .offset(x: shift ? geo.size.width * 0.5 : -geo.size.width * 0.5,
                                y: CGFloat(i * 120))
                        .animation(.linear(duration: 50)
                            .repeatForever(autoreverses: true), value: shift)
                }
            }
            .onAppear { shift = true }
        }
    }
}

struct RainLayer: View {
    var isNight: Bool = false

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<180 {
                    let x = CGFloat.random(in: 0...size.width)
                    var y = (CGFloat(time * 250) + CGFloat(i * 25))
                        .truncatingRemainder(dividingBy: size.height)
                    y -= size.height / 2

                    let rect = CGRect(x: x, y: y, width: 1.3, height: 18)
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 0.6),
                        with: .color(isNight ? .white.opacity(0.25) : .white.opacity(0.4))
                    )
                }
            }
        }
    }
}

struct SnowLayer: View {
    var isNight: Bool = false

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<120 {
                    let x = CGFloat(i) / 120 * size.width
                    var y = (CGFloat(time * 35) + CGFloat(i * 45))
                        .truncatingRemainder(dividingBy: size.height)
                    y -= size.height / 2

                    let drift = CGFloat.random(in: -15...15) * sin(CGFloat(time) / 2)
                    let circle = Path(ellipseIn: CGRect(x: x + drift, y: y, width: 5, height: 5))
                    context.fill(circle, with: .color(isNight ? .white.opacity(0.7) : .white))
                }
            }
        }
    }
}

struct ThunderstormLayer: View {
    var isNight: Bool = false
    @State private var flash = false

    var body: some View {
        ZStack {
            Color.white
                .opacity(flash ? (isNight ? 0.45 : 0.6) : 0.0)
                .ignoresSafeArea()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...7), repeats: true) { _ in
                withAnimation(.easeOut(duration: 0.12)) { flash = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeIn(duration: 0.3)) { flash = false }
                }
            }
        }
    }
}

struct MoonGlowView: View {
    @State private var pulse = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            // Main glow
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [
                        .white.opacity(0.95),
                        .white.opacity(0.6),
                        .clear
                    ]), center: .center, startRadius: 0, endRadius: 250)
                )
                .blur(radius: 40)
                .opacity(0.8)

            // Moon itself
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [
                        .white,
                        .gray.opacity(0.3),
                        .gray.opacity(0.4)
                    ]), center: .topLeading, startRadius: 10, endRadius: 130)
                )
                .overlay(
                    // Crater simulation
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 12, height: 12).offset(x: -30, y: -10)
                        Circle().fill(Color.gray.opacity(0.25)).frame(width: 9, height: 9).offset(x: 25, y: 20)
                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 14, height: 14).offset(x: -15, y: 30)
                    }
                    .blur(radius: 1.5)
                )
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: rotate)

            // Soft outer glow
            Circle()
                .stroke(Color.white.opacity(pulse ? 0.5 : 0.2), lineWidth: 12)
                .blur(radius: 25)
                .scaleEffect(pulse ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulse)
        }
        .frame(width: 180, height: 180)
        .offset(x: 110, y: -260)
        .onAppear {
            pulse = true
            rotate = true
        }
    }
}

struct MainPreviews: PreviewProvider {
    static var previews: some View {
        // Простой Preview без ApplicationViewBuilder
        Text("Main View Preview")
    }
}

