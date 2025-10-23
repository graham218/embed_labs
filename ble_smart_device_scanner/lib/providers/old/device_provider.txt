import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device.dart';
import '../services/ble_service.dart';

final deviceProvider = StateNotifierProvider.family<DeviceNotifier, DeviceState, BleDevice>((ref, device) => DeviceNotifier(device));

class DeviceState {
  final BleDevice device;
  final BluetoothDeviceState connectionState;
  final List<BluetoothService> services;
  final String? manufacturerName;
  final String? error;

  DeviceState({
    required this.device,
    this.connectionState = BluetoothDeviceState.disconnected,
    this.services = const [],
    this.manufacturerName,
    this.error,
  });

  DeviceState copyWith({
    BluetoothDeviceState? connectionState,
    List<BluetoothService>? services,
    String? manufacturerName,
    String? error,
  }) {
    return DeviceState(
      device: device,
      connectionState: connectionState ?? this.connectionState,
      services: services ?? this.services,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      error: error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  final BleService _bleService = BleService();

  DeviceNotifier(BleDevice device) : super(DeviceState(device: device)) {
    _listenToConnectionState();
  }

  void _listenToConnectionState() {
    state.device.device.state.listen((BluetoothDeviceState newState) {
      state = state.copyWith(connectionState: newState);
      if (newState == BluetoothDeviceState.disconnected && state.connectionState != BluetoothDeviceState.disconnecting) {
        _autoReconnect();
      }
    });
  }

  Future<void> connect() async {
    try {
      state = state.copyWith(connectionState: BluetoothDeviceState.connecting, error: null);
      final services = await _bleService.connectAndDiscover(state.device.device);
      final manufacturerName = await _bleService.readManufacturerName(state.device.device);
      state = state.copyWith(services: services, manufacturerName: manufacturerName, connectionState: BluetoothDeviceState.connected);
    } catch (e) {
      state = state.copyWith(error: 'Connection failed: $e', connectionState: BluetoothDeviceState.disconnected);
    }
  }

  Future<void> disconnect() async {
    try {
      await state.device.device.disconnect();
      state = state.copyWith(connectionState: BluetoothDeviceState.disconnected, services: [], error: null);
    } catch (e) {
      state = state.copyWith(error: 'Disconnection failed: $e');
    }
  }

  Future<void> _autoReconnect() async {
    for (int i = 0; i < 2; i++) {
      try {
        state = state.copyWith(connectionState: BluetoothDeviceState.connecting, error: null);
        final services = await _bleService.connectAndDiscover(state.device.device);
        final manufacturerName = await _bleService.readManufacturerName(state.device.device);
        state = state.copyWith(services: services, manufacturerName: manufacturerName, connectionState: BluetoothDeviceState.connected);
        return;
      } catch (e) {
        state = state.copyWith(error: 'Reconnection attempt ${i + 1} failed: $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    state = state.copyWith(connectionState: BluetoothDeviceState.disconnected);
  }
}