# 📍 Location Tracker
<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.27.4-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.6.2-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android-green.svg)

*A Flutter application that provides real-time location tracking with background service capabilities. The app allows users to track their routes, view path history, and manage multiple tracking sessions.* 

[Features](#-features) • 
[Installation](#-installation) • 
[Architecture](#-architecture) • 
[Documentation](#-documentation) • 
[License](#-license)

</div>

---

## ⚠️ Platform Support

- ✅ **Android**: Fully supported with background location tracking
- ⚠️ **iOS**: Basic functionality available, but background location tracking is not currently implemented

## ✨ Features

<div align="center">
  <img src="/api/placeholder/800/400" alt="App Screenshot">
</div>

- 🗺️ **Real-time Tracking** (Android)
  - Background location updates
  - Smooth path visualization
  - Multiple tracking sessions

- 🔋 **Key Features**
  - **Persistent Background Tracking** - Continues location collection even when app is terminated (Android)
  - **Offline Resilience** - Full tracking functionality without internet connection

- 📊 **Advanced Statistics**
  - Duration tracking
  - Distance calculation
  - Average speed monitoring

- 🛠️ **Powerful Tools**
  - Track history management
  - Route optimization

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Manas-Basnet51/location_tracker.git
   ```

2. **Install dependencies**
   ```bash
   cd location_tracker
   flutter pub get
   ```

3. **Configure Android Permissions**
   
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure
```
```

## 📚 Documentation
### Packages Used
- flutter_background_service - For running location updates in background
- flutter_local_notification
- hive_ce & hive_ce_flutter - For local storage
- geolocator - For persistent location updates
- flutter_map - For map integration

### Core Components

<details>
<summary><b>🔄 Background Service Handler (Android)</b></summary>

```dart
/// Manages background location tracking functionality for Android
class BackgroundServiceHandler {
  // Implementation details...
}
```
</details>

<details>
<summary><b>🗺️ Location Repository</b></summary>

```dart
/// Handles location data persistence
class LocationRepository {
  // Implementation details...
}
```
</details>

## 🛠️ Tech Stack

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](#)
[![GetIt](https://img.shields.io/badge/GetIt-orange?style=for-the-badge)](#)
[![Hive](https://img.shields.io/badge/Hive-yellow?style=for-the-badge)](#)

</div>

## 🚧 Known Limitations

### Platform Limitations
- Background location tracking is currently only implemented for Android
- iOS implementation is pending due to development environment constraints
- Some features may not work as expected on iOS devices

### Technical Limitations
- Permission handling needs improvement:
  - Better user guidance needed when permissions are denied
  - More robust error handling for permission-related exceptions
  - Enhanced navigation to system settings when required

- Navigation and routing:
  - Current routing implementation is basic
  - Planned migration to more efficient solutions like `go_router`

- Data Synchronization:
  - Background to UI data synchronization requires optimization
  - Real-time updates can be more efficient

- Map Functionality:
  - Offline map support is not yet implemented
  - Map caching capabilities are limited
  - Limited map customization options

- Battery Optimization:
  - Background service may not be battery-efficient

<div align="center">

Made with ❤️ by Manas Basnet

</div>
>>>>>>> 066c49a (Initial commit)
