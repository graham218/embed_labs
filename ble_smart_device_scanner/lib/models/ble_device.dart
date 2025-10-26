import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDevice device;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.device,
  });

  static BleDevice fromScanResult(ScanResult r) {
    final rawName = r.advertisementData.localName;
    final displayName = (rawName?.isNotEmpty == true)
        ? rawName!
        : 'BLE Device (${r.device.remoteId.str.substring(0, 8).toUpperCase()})';

    return BleDevice(
      id: r.device.remoteId.str,
      name: displayName.trim(),
      rssi: r.rssi,
      device: r.device,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BleDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}