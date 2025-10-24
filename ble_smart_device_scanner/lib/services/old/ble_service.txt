import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        // Android 12+
        final scanStatus = await Permission.bluetoothScan.request();
        final connectStatus = await Permission.bluetoothConnect.request();
        if (!scanStatus.isGranted || !connectStatus.isGranted) {
          return false;
        }
      } else {
        // Android < 12
        final locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          return false;
        }
      }
    } else if (Platform.isIOS) {
      // iOS: Location is required for BLE
      final locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      return false;
    }
    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
      state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    }
    return true;
  }

  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<List<BluetoothService>> connectAndDiscover(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));
      return await device.discoverServices();
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<String?> readManufacturerName(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      final deviceInfoService = services.firstWhere(
            (s) => s.serviceUuid == Guid('0000180A-0000-1000-8000-00805F9B34FB'),
        orElse: () => throw Exception('Device Information Service not found'),
      );
      final manufacturerChar = deviceInfoService.characteristics.firstWhere(
            (c) => c.characteristicUuid == Guid('00002A29-0000-1000-8000-00805F9B34FB'),
        orElse: () => throw Exception('Manufacturer Name characteristic not found'),
      );
      final value = await manufacturerChar.read();
      return String.fromCharCodes(value);
    } catch (e) {
      return null;
    }
  }
}