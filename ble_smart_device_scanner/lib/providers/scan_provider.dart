import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ble_device.dart';
import '../services/ble_service.dart';

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) => ScanNotifier(ref));

class ScanState {
  final List<BleDevice> devices;
  final bool isScanning;
  final String filterQuery;
  final String filterType;
  final bool showOnlyBleDevices;
  final String? error;

  ScanState({
    this.devices = const [],
    this.isScanning = false,
    this.filterQuery = '',
    this.filterType = 'All',
    this.showOnlyBleDevices = false,
    this.error,
  });

  ScanState copyWith({
    List<BleDevice>? devices,
    bool? isScanning,
    String? filterQuery,
    String? filterType,
    bool? showOnlyBleDevices,
    String? error,
  }) {
    return ScanState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      filterQuery: filterQuery ?? this.filterQuery,
      filterType: filterType ?? this.filterType,
      showOnlyBleDevices: showOnlyBleDevices ?? this.showOnlyBleDevices,
      error: error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final Ref ref;
  final BleService _bleService = BleService();
  List<BleDevice> _allDevices = [];
  bool _isBleScanning = false;
  bool _isClassicScanning = false;

  ScanNotifier(this.ref) : super(ScanState());

  Future<void> startScan() async {
    if (!await _bleService.checkPermissions()) {
      state = state.copyWith(error: 'Permissions denied. Please grant Bluetooth and Location permissions.');
      return;
    }
    if (!await _bleService.checkBluetooth()) {
      state = state.copyWith(error: 'Bluetooth is off or unsupported.');
      return;
    }

    state = state.copyWith(isScanning: true, error: null, devices: []);
    _allDevices.clear();

    // Start BLE scanning
    await _startBleScan();

    // Start Classic Bluetooth scanning
    await _startClassicBluetoothScan();
  }

  Future<void> _startBleScan() async {
    _isBleScanning = true;

    try {
      final subscription = _bleService.startBleScan().listen((results) {
        if (results.isNotEmpty && _isBleScanning) {
          final newDevices = results.map((r) => BleDevice.fromScanResult(r)).toList();

          // Update the complete list of all devices
          for (final newDevice in newDevices) {
            final existingIndex = _allDevices.indexWhere((d) => d.id == newDevice.id && d.type == DeviceType.ble);
            if (existingIndex >= 0) {
              _allDevices[existingIndex] = newDevice; // Update existing device
            } else {
              _allDevices.add(newDevice); // Add new device
            }
          }

          // Update state with filtered devices
          state = state.copyWith(
            devices: List<BleDevice>.from(_allDevices),
            isScanning: true,
          );
        }
      });

      // Stop BLE scan after 15 seconds
      await Future.delayed(const Duration(seconds: 15));
      subscription.cancel();
      _isBleScanning = false;

    } catch (e) {
      _isBleScanning = false;
      state = state.copyWith(error: 'BLE Scan failed: $e');
    }
  }

  Future<void> _startClassicBluetoothScan() async {
    _isClassicScanning = true;

    try {
      final subscription = _bleService.startClassicBluetoothScan().listen((devices) {
        if (devices.isNotEmpty && _isClassicScanning) {
          final newDevices = devices.map((device) => BleDevice.fromClassicDevice(device, bonded: device.isBonded)).toList();

          // Update the complete list of all devices
          for (final newDevice in newDevices) {
            final existingIndex = _allDevices.indexWhere((d) => d.id == newDevice.id && d.type == DeviceType.classic);
            if (existingIndex >= 0) {
              _allDevices[existingIndex] = newDevice; // Update existing device
            } else {
              _allDevices.add(newDevice); // Add new device
            }
          }

          // Update state with filtered devices
          state = state.copyWith(
            devices: List<BleDevice>.from(_allDevices),
            isScanning: true,
          );
        }
      });

      // Stop classic scan after 15 seconds
      await Future.delayed(const Duration(seconds: 15));
      subscription.cancel();
      _isClassicScanning = false;

      // Update scanning state when both scans complete
      if (!_isBleScanning) {
        state = state.copyWith(isScanning: false);
      }

    } catch (e) {
      _isClassicScanning = false;
      if (!_isBleScanning) {
        state = state.copyWith(isScanning: false);
      }
      state = state.copyWith(error: 'Classic Bluetooth Scan failed: $e');
    }
  }

  void stopScan() {
    _isBleScanning = false;
    _isClassicScanning = false;
    _bleService.stopBleScan();
    _bleService.stopClassicBluetoothScan();
    state = state.copyWith(isScanning: false);
  }

  void setFilterQuery(String query) {
    state = state.copyWith(filterQuery: query);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  void toggleBleOnlyFilter(bool value) {
    state = state.copyWith(showOnlyBleDevices: value);
  }

  List<BleDevice> getFilteredDevices() {
    var devices = List<BleDevice>.from(state.devices);

    // Filter by BLE only if toggle is enabled
    if (state.showOnlyBleDevices) {
      devices = devices.where((d) => d.type == DeviceType.ble).toList();
    }

    // Filter by query
    if (state.filterQuery.isNotEmpty) {
      devices = devices.where((d) =>
      d.name.toLowerCase().contains(state.filterQuery.toLowerCase()) ||
          d.id.toLowerCase().contains(state.filterQuery.toLowerCase()) ||
          d.deviceTypeString.toLowerCase().contains(state.filterQuery.toLowerCase())
      ).toList();
    }

    // Filter by device type
    if (state.filterType == 'Audio Devices') {
      devices = devices.where((d) =>
      d.name.toLowerCase().contains('headphone') ||
          d.name.toLowerCase().contains('earbud') ||
          d.name.toLowerCase().contains('speaker') ||
          d.name.toLowerCase().contains('audio')).toList();
    } else if (state.filterType == 'Smartwatches') {
      devices = devices.where((d) =>
      d.name.toLowerCase().contains('watch') ||
          d.name.toLowerCase().contains('fitbit') ||
          d.name.toLowerCase().contains('galaxy') ||
          d.name.toLowerCase().contains('apple')).toList();
    } else if (state.filterType == 'Phones') {
      devices = devices.where((d) =>
      d.name.toLowerCase().contains('phone') ||
          d.name.toLowerCase().contains('iphone') ||
          d.name.toLowerCase().contains('samsung') ||
          d.name.toLowerCase().contains('android')).toList();
    }

    // Remove duplicates by ID and sort by device type and RSSI
    final uniqueDevices = <String, BleDevice>{};
    for (final device in devices) {
      uniqueDevices[device.id] = device;
    }

    return uniqueDevices.values.toList()
      ..sort((a, b) {
        // Sort by type (BLE first), then by RSSI (strongest first)
        if (a.type != b.type) {
          return a.type == DeviceType.ble ? -1 : 1;
        }
        return b.rssi.compareTo(a.rssi);
      });
  }
}