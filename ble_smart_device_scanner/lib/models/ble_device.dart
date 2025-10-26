

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceType {
  ble,
  classic,
}

class BleDevice {
  final DeviceType type;
  final BluetoothDevice? bleDevice;
  final BluetoothDevice? classicDevice;
  final String name;
  final String id;
  final int rssi;
  final bool isBonded;

  BleDevice.fromScanResult(ScanResult result)
      : type = DeviceType.ble,
        bleDevice = result.device,
        classicDevice = null,
        name = result.device.platformName.isNotEmpty ? result.device.platformName : 'Unknown BLE Device',
        id = result.device.remoteId.toString(),
        rssi = result.rssi,
        isBonded = false;

  BleDevice.fromClassicDevice(BluetoothDevice device, {int rssiValue = -100, bool bonded = false})
      : type = DeviceType.classic,
        bleDevice = null,
        classicDevice = device,
        name = device.name ?? 'Unknown Classic Device',
        id = device.address,
        rssi = rssiValue,
        isBonded = bonded;

  String get deviceTypeString {
    return type == DeviceType.ble ? 'BLE Device' : 'Classic Bluetooth';
  }

  String get connectionStatus {
    if (type == DeviceType.ble) {
      return 'Disconnected'; // BLE connection state is managed separately
    } else {
      return classicDevice?.isConnected == true ? 'Connected' : 'Disconnected';
    }
  }
}