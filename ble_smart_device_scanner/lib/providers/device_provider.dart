import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device.dart';
import '../services/ble_service.dart';

final deviceProvider = StateNotifierProvider.family<DeviceNotifier, DeviceState, BleDevice>(
      (ref, device) => DeviceNotifier(device),
);

class DeviceState {
  final BleDevice device;
  final BluetoothDeviceState connectionState;
  final List<BluetoothService> services;
  final String? manufacturerName;
  final int? batteryLevel;
  final List<int> rssiHistory;
  final String? error;

  DeviceState({
    required this.device,
    this.connectionState = BluetoothDeviceState.disconnected,
    this.services = const [],
    this.manufacturerName,
    this.batteryLevel,
    this.rssiHistory = const [],
    this.error,
  });

  DeviceState copyWith({
    BluetoothDeviceState? connectionState,
    List<BluetoothService>? services,
    String? manufacturerName,
    int? batteryLevel,
    List<int>? rssiHistory,
    String? error,
  }) {
    return DeviceState(
      device: device,
      connectionState: connectionState ?? this.connectionState,
      services: services ?? this.services,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      rssiHistory: rssiHistory ?? this.rssiHistory,
      error: error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  final BleService _bleService = BleService();
  StreamSubscription<int>? _rssiSubscription;

  DeviceNotifier(BleDevice device) : super(DeviceState(device: device)) {
    _listenToConnectionState();
  }

  @override
  void dispose() {
    _rssiSubscription?.cancel();
    super.dispose();
  }

  void _listenToConnectionState() {
    state.device.device.connectionState.listen((BluetoothConnectionState s) {
      final deviceState = _toDeviceState(s);
      state = state.copyWith(connectionState: deviceState);
      if (deviceState == BluetoothDeviceState.disconnected &&
          state.connectionState != BluetoothDeviceState.disconnecting) {
        _autoReconnect();
      }
    });
  }

  BluetoothDeviceState _toDeviceState(BluetoothConnectionState s) {
    return BluetoothDeviceState.values.firstWhere(
          (e) => e.toString() == 'BluetoothDeviceState.${s.name}',
      orElse: () => BluetoothDeviceState.disconnected,
    );
  }

  Future<void> connect() async {
    try {
      state = state.copyWith(connectionState: BluetoothDeviceState.connecting, error: null);
      final services = await _bleService.connectAndDiscover(state.device.device);
      final manufacturer = await _bleService.readManufacturerName(state.device.device);
      final battery = await _bleService.readBatteryLevel(state.device.device);

      // Start RSSI streaming
      final rssiStream = _bleService.streamRssi(state.device.device);
      _rssiSubscription = rssiStream.listen((rssi) {
        final history = [...state.rssiHistory, rssi];
        if (history.length > 30) history.removeAt(0);
        state = state.copyWith(rssiHistory: history);
      });

      state = state.copyWith(
        services: services,
        manufacturerName: manufacturer,
        batteryLevel: battery,
        connectionState: BluetoothDeviceState.connected,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Connection failed: $e',
        connectionState: BluetoothDeviceState.disconnected,
      );
    }
  }

  Future<void> disconnect() async {
    _rssiSubscription?.cancel();
    try {
      await state.device.device.disconnect();
      state = state.copyWith(
        connectionState: BluetoothDeviceState.disconnected,
        services: [],
        batteryLevel: null,
        rssiHistory: [],
      );
    } catch (e) {
      state = state.copyWith(error: 'Disconnect failed: $e');
    }
  }

  Future<void> _autoReconnect() async {
    for (int i = 0; i < 2; i++) {
      try {
        state = state.copyWith(connectionState: BluetoothDeviceState.connecting);
        final services = await _bleService.connectAndDiscover(state.device.device);
        final manufacturer = await _bleService.readManufacturerName(state.device.device);
        final battery = await _bleService.readBatteryLevel(state.device.device);
        state = state.copyWith(
          services: services,
          manufacturerName: manufacturer,
          batteryLevel: battery,
          connectionState: BluetoothDeviceState.connected,
        );
        return;
      } catch (e) {
        state = state.copyWith(error: 'Reconnect ${i + 1} failed');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    state = state.copyWith(connectionState: BluetoothDeviceState.disconnected);
  }
}