import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDevice {
  final BluetoothDevice device;
  final String name;
  final String id;
  final int rssi;

  BleDevice.fromScanResult(ScanResult result)
      : device = result.device,
        name = result.device.platformName.isNotEmpty ? result.device.platformName : 'Unknown Device',
        id = result.device.remoteId.toString(),
        rssi = result.rssi;
}