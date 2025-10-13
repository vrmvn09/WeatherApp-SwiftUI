WeatherApp (SwiftUI) – Setup and GitHub Deployment Guide

Overview

WeatherApp is a SwiftUI application using a lightweight VIPER-like architecture and a small DI container. Networking is performed via URLSession to the OpenWeather API.

Key features
- Search cities and view current weather
- My Location support (Core Location)
- Saved cities list with swipe-to-delete and edit mode
- Simple persistence (UserDefaults + JSON file in Documents)

Requirements
- Xcode 15+ (iOS 17 SDK or newer recommended)
- iOS 16+ target (can be adjusted in project settings)
- OpenWeather API key

Project structure (high level)
- WeatherApp/RootApp.swift, RootView.swift – app entry and navigation host
- Classes/Modules/Main – Main module (Presenter/Interactor/View/ViewState/Router)
- Classes/Services/NavigationService – Navigation service, Network service, Location manager
- Resources/ – Assets and Info.plist

Obtaining an OpenWeather API key
1) Create an account at https://openweathermap.org/
2) Create an API key and copy it
3) Add key to Info.plist → OPENWEATHER_API_KEY string value

Build and run (locally)
1) Open WeatherApp.xcodeproj in Xcode
2) Select a Simulator or a physical device
3) Product → Run (Cmd+R)

Location permissions on device
- If the permission dialog does not appear: go to iOS Settings → the app → Location → set While Using the App, then relaunch the app.

Environment configuration
- The app reads the OpenWeather key from Info.plist (key: OPENWEATHER_API_KEY)
- If you ever need per-environment keys, you can add an xcconfig and reference it from Info.plist using ${VARIABLE}

Persisted data
- Saved cities are persisted to UserDefaults and mirrored to Documents/saved_cities.json. This survives normal restarts; deleting the app removes data.

Deploying to GitHub (new repository)
Assumes you have git installed and a GitHub account.

1) Initialize git in the project root
```bash
cd /path/to/WeatherApp
git init
git add .
git commit -m "chore: initial commit"
```

2) Create a new empty repository on GitHub (without README/.gitignore). Copy its URL, e.g.:
```
https://github.com/<your-username>/WeatherApp.git
```

3) Add remote and push
```bash
git branch -M main
git remote add origin https://github.com/<your-username>/WeatherApp.git
git push -u origin main
```

Updating code later
```bash
git add -A
git commit -m "feat: <short description>"
git push
```

Recommended .gitignore
If needed, generate one for Xcode/Swift and place it at the repo root.
```gitignore
DerivedData/
build/
.DS_Store
xcuserdata/
*.xcuserstate
```

Optional: GitHub Actions (CI build)
You can create .github/workflows/ios-build.yml to build the project on push. Example (simplified):
```yaml
name: iOS Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Xcode build
        run: xcodebuild -project WeatherApp.xcodeproj -scheme WeatherApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build | xcpretty
```

Security notes
- Do not commit real API keys. For public repos, consider removing OPENWEATHER_API_KEY from Info.plist and using a sample value with instructions, or leveraging CI secrets.

License
- Add your preferred license (e.g., MIT) at the repo root if publishing publicly.


