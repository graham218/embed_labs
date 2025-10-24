<!-- HEADER -->
<h1 align="center">
  <img src="https://img.icons8.com/color/96/000000/bluetooth--v2.png" width="70"/>
  <br>
  BLE Smart Device Scanner
</h1>

<p align="center">
  <b>A modern Flutter app for scanning, connecting, and managing Bluetooth Low Energy (BLE) devices.</b><br>
  Built with ❤️ by <a href="https://github.com/graham218">Graham Bill</a>  
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-blue?logo=flutter&logoColor=white&style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge&logo=android&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
</p>

---

## ✨ Overview

🚀 **BLE Smart Device Scanner** is a beautifully crafted Flutter application that enables you to **discover**, **connect**, and **interact** with Bluetooth Low Energy (BLE) devices around you — from smartwatches to audio peripherals.

It features smooth animations, a Material 3 design system, and robust error handling — ensuring a seamless and responsive experience across all device sizes.

---

## 🧭 Features

<div align="center">

| 🧩 Core Feature | 💡 Description |
|-----------------|----------------|
| 🔍 **Real-time BLE Scanning** | Discover nearby BLE devices with instant updates. |
| 🏷️ **Device Details** | View device name, ID, RSSI, and manufacturer data. |
| 🧠 **Smart Filtering** | Filter by name or type (Audio Devices, Smartwatches, etc.). |
| 🔗 **Connection Handling** | Connect to and explore device services & characteristics. |
| 🔁 **Auto-Reconnect** | Reconnect automatically up to 2 times on disconnection. |
| 📱 **Responsive Design** | Works beautifully on phones, tablets, and desktops. |

</div>

---

## 🛠️ Tech Stack

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-blue?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-2.5.1-purple?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/flutter_blue_plus-1.32.8-lightblue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/permission_handler-11.3.1-orange?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/intl-0.19.0-lightgrey?style=for-the-badge"/>
</p>

---

## ⚙️ Setup Instructions

### 1️⃣ Prerequisites
- 🧰 **Flutter SDK 3.24.3+**
- 📱 **Physical Android/iOS device** (emulators may not support BLE)
- 🔋 **Bluetooth enabled**

### 2️⃣ Installation Steps
```bash
# Clone the repository
git clone https://github.com/graham218/embed_labs.git

# Navigate to the project
cd embed_labs/ble_smart_device_scanner

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 3️⃣ Configure Permissions

#### 🟩 Android:
Add permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

#### 🍎 iOS:
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to nearby devices.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is needed to scan for nearby BLE devices.</string>
```

---

## 🧠 State Management

> Powered by **Riverpod** for structured and reactive state updates.

- **`ScanProvider`** handles BLE scanning streams.
- **`DeviceProvider`** manages connections and device services.
- Each layer is modular and reusable — ideal for scaling IoT-based Flutter apps.

---

## 🧩 Challenges & Solutions

| Challenge | Solution |
|------------|-----------|
| 🧱 Android 12+ Bluetooth permissions | Used `permission_handler` with user-friendly prompts. |
| ⚡ Real-time updates | Leveraged `StreamBuilder` for BLE scan/connection streams. |
| 💻 Screen Responsiveness | `LayoutBuilder` adapts to mobile, tablet, and desktop screens. |
| 🏭 Manufacturer details | Integrated `Device Information Service` for metadata. |
| 🔁 Auto Reconnect | Implemented retry logic with safe fallback on failure. |

---

## 📸 Screenshots / Demo

<p align="center">
  <img src="https://github.com/graham218/embed_labs/assets/demo1.gif" width="250" style="box-shadow: 0 4px 12px rgba(0,0,0,0.2); border-radius: 16px;"/>
  <img src="https://github.com/graham218/embed_labs/assets/demo2.gif" width="250" style="box-shadow: 0 4px 12px rgba(0,0,0,0.2); border-radius: 16px;"/>
  <br>
  <em>Beautiful, smooth, and responsive — optimized for all screen sizes.</em>
</p>

---

## 📂 Project Structure

```
ble_smart_device_scanner/
│
├── lib/
│   ├── models/              # BLE device data models
│   ├── providers/           # Riverpod state providers
│   ├── screens/             # App screens (Scan, Device Details)
│   ├── widgets/             # Reusable UI components
│   └── main.dart            # Entry point
│
├── android/                 # Android-specific config
├── ios/                     # iOS-specific config
└── pubspec.yaml             # Dependencies & metadata
```

---

## 📞 Contact

<div align="center">

💬 **Developed by:** [Graham Bill](https://github.com/graham218)  
📧 **Email:** [grahambill011@gmail.com](mailto:grahambill011@gmail.com)  
📱 **Phone:** +254 790 613 916  
💻 **GitHub:** [github.com/graham218](https://github.com/graham218)

</div>

---

## 🌟 Contribute
Want to improve this project? Fork it, make changes, and create a pull request!  
Contributions are always welcome 🙌

```bash
# Fork the repo
git clone https://github.com/graham218/embed_labs.git
# Create a feature branch
git checkout -b feature/amazing-update
# Commit changes
git commit -m "Added new feature"
# Push
git push origin feature/amazing-update
```

---

## 🪪 License
This project is licensed under the [MIT License](LICENSE).

---

<p align="center">
  <img src="https://img.icons8.com/color/96/bluetooth--v1.png" width="60" alt="Bluetooth Icon"/>
  <br><br>
  <b>BLE Smart Device Scanner</b> — Built with Flutter 💙
</p>

