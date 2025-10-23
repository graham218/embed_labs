# BLE Scanner App

A Flutter application for scanning and connecting to Bluetooth Low Energy (BLE) devices, built with Material 3 design and robust error handling.

## Features
- Scans for BLE devices with real-time updates.
- Displays device name, ID, and RSSI.
- Filters devices by name or type (All, Audio Devices, Smartwatches).
- Connects to a selected device, discovers services and characteristics.
- Displays manufacturer name (Device Information service).
- Auto-reconnects on unexpected disconnection (up to 2 attempts).
- Responsive UI for mobile and tablet screens.

## Prerequisites
- Flutter 3.24.3 or later
- Physical Android/iOS device with Bluetooth support (emulators may not support BLE)

## Setup Instructions
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Ensure Android/iOS permissions are configured:
    - Android: Permissions in `android/app/src/main/AndroidManifest.xml`.
    - iOS: Bluetooth and location descriptions in `ios/Runner/Info.plist`.
4. Connect a physical device.
5. Run `flutter run` to launch the app.

## Dependencies
- `flutter_blue_plus: ^1.32.8` - BLE functionality
- `permission_handler: ^11.3.1` - Runtime permissions
- `flutter_riverpod: ^2.5.1` - State management
- `intl: ^0.19.0` - Formatting (if needed)

## State Management
Used `flutter_riverpod` for its reactive stream handling, ideal for BLE scan results and connection state updates. Providers manage scan and device states separately for modularity.

## Challenges and Solutions
- **Permissions**: Handled Android 12+ BLUETOOTH_SCAN/CONNECT permissions using `permission_handler`, with user-friendly error messages.
- **Real-time Updates**: Leveraged `StreamBuilder` for scan results and connection states.
- **Responsiveness**: Used `LayoutBuilder` to switch between `ListView` and `GridView` on larger screens.
- **Bonus Features**: Implemented manufacturer name reading and auto-reconnect logic.

## Running the App
1. Ensure Bluetooth is enabled on your device.
2. Grant Bluetooth and location permissions when prompted.
3. Use the "Start Scan" button to discover devices.
4. Filter devices by name or type (e.g., Audio Devices for UUID 0x110B).
5. Tap a device to view details, connect, and see services/characteristics.