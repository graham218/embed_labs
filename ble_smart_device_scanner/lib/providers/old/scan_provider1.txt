import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ble_device.dart';
import '../services/ble_service.dart';

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) => ScanNotifier(ref));

class ScanState {
  final List<BleDevice> devices;
  final bool isScanning;
  final String filterQuery;
  final String filterType;
  final String? error;

  ScanState({
    this.devices = const [],
    this.isScanning = false,
    this.filterQuery = '',
    this.filterType = 'All',
    this.error,
  });

  ScanState copyWith({
    List<BleDevice>? devices,
    bool? isScanning,
    String? filterQuery,
    String? filterType,
    String? error,
  }) {
    return ScanState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      filterQuery: filterQuery ?? this.filterQuery,
      filterType: filterType ?? this.filterType,
      error: error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final Ref ref;
  final BleService _bleService = BleService();

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
    state = state.copyWith(isScanning: true, error: null);
    _bleService.startScan().listen(
          (results) {
        state = state.copyWith(
          devices: results.map((r) => BleDevice.fromScanResult(r)).toList(),
          isScanning: true,
        );
      },
      onError: (e) {
        state = state.copyWith(error: 'Scan failed: $e', isScanning: false);
      },
      onDone: () {
        state = state.copyWith(isScanning: false);
      },
    );
  }

  void stopScan() {
    _bleService.stopScan();
    state = state.copyWith(isScanning: false);
  }

  void setFilterQuery(String query) {
    state = state.copyWith(filterQuery: query);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  // Add this method to get filtered devices
  List<BleDevice> getFilteredDevices() {
    var devices = state.devices;
    if (state.filterQuery.isNotEmpty) {
      devices = devices.where((d) => d.name.toLowerCase().contains(state.filterQuery.toLowerCase())).toList();
    }
    if (state.filterType == 'Audio Devices') {
      // Use manufacturer data or name for audio device detection
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
    }
    return devices;
  }
}