import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ble_device.dart';
import '../providers/device_provider.dart';
import '../widgets/service_tile.dart';

class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleDevice? device = ModalRoute.of(context)!.settings.arguments as BleDevice?;
    if (device == null) {
      return const Scaffold(body: Center(child: Text('No device selected')));
    }

    final deviceState = ref.watch(deviceProvider(device));

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${device.id}\nRSSI: ${device.rssi} dBm',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (deviceState.manufacturerName != null)
              Text(
                'Manufacturer: ${deviceState.manufacturerName}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(deviceState.connectionState == BluetoothDeviceState.connected ? Icons.link_off : Icons.link),
              label: Text(
                deviceState.connectionState == BluetoothDeviceState.connected
                    ? 'Disconnect'
                    : deviceState.connectionState == BluetoothDeviceState.connecting
                    ? 'Connecting...'
                    : 'Connect',
              ),
              onPressed: deviceState.connectionState == BluetoothDeviceState.connecting
                  ? null
                  : deviceState.connectionState == BluetoothDeviceState.connected
                  ? () => ref.read(deviceProvider(device).notifier).disconnect()
                  : () => ref.read(deviceProvider(device).notifier).connect(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (deviceState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  deviceState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: deviceState.connectionState == BluetoothDeviceState.connecting
                  ? const Center(child: CircularProgressIndicator())
                  : deviceState.services.isEmpty
                  ? const Center(child: Text('Connect to discover services'))
                  : ListView.builder(
                itemCount: deviceState.services.length,
                itemBuilder: (context, index) {
                  return ServiceTile(service: deviceState.services[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}