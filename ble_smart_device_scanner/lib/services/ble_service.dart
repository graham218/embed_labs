import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  // --- Permissions ---
  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final scan = await Permission.bluetoothScan.request();
        final connect = await Permission.bluetoothConnect.request();
        return scan.isGranted && connect.isGranted;
      } else {
        final location = await Permission.location.request();
        return location.isGranted;
      }
    } else if (Platform.isIOS) {
      final location = await Permission.locationWhenInUse.request();
      return location.isGranted;
    }
    return true;
  }

  // --- Bluetooth State ---
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) return false;
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
      return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    }
    return true;
  }

  // --- Scan ---
  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() => FlutterBluePlus.stopScan();

  // --- Connect & Discover ---
  Future<List<BluetoothService>> connectAndDiscover(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 15));
    return await device.discoverServices();
  }

  // --- Read Manufacturer ---
  Future<String?> readManufacturerName(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      final info = services.firstWhere(
            (s) => s.serviceUuid == Guid('0000180A-0000-1000-8000-00805F9B34FB'),
        orElse: () => throw Exception(),
      );
      final char = info.characteristics.firstWhere(
            (c) => c.characteristicUuid == Guid('00002A29-0000-1000-8000-00805F9B34FB'),
        orElse: () => throw Exception(),
      );
      final data = await char.read();
      return String.fromCharCodes(data);
    } catch (_) {
      return null;
    }
  }

  // --- NEW: Read Battery Level ---
  Future<int?> readBatteryLevel(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      final batteryService = services.firstWhere(
            (s) => s.serviceUuid.toString().startsWith('0000180f'),
        orElse: () => throw Exception('Battery Service not found'),
      );
      final batteryChar = batteryService.characteristics.firstWhere(
            (c) => c.characteristicUuid.toString().startsWith('00002a19'),
      );
      final value = await batteryChar.read();
      return value.isNotEmpty ? value[0] : null;
    } catch (_) {
      return null;
    }
  }

  // --- NEW: Stream RSSI ---
  Stream<int> streamRssi(BluetoothDevice device) async* {
    while (true) {
      try {
        final rssi = await device.readRssi();
        yield rssi;
      } catch (_) {
        yield -100;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}