import 'package:fl_chart/fl_chart.dart';
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
    final device = ModalRoute.of(context)!.settings.arguments as BleDevice?;
    if (device == null) return const Scaffold(body: Center(child: Text('No device')));

    final state = ref.watch(deviceProvider(device));

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.id}\nRSSI: ${device.rssi} dBm', style: const TextStyle(fontSize: 16)),
            if (state.manufacturerName != null)
              Text('Manufacturer: ${state.manufacturerName}', style: const TextStyle(fontSize: 16)),
            if (state.batteryLevel != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.battery_std, color: _batteryColor(state.batteryLevel!)),
                    const SizedBox(width: 8),
                    Text('${state.batteryLevel}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: Icon(state.connectionState == BluetoothDeviceState.connected ? Icons.link_off : Icons.link),
              label: Text(state.connectionState == BluetoothDeviceState.connected
                  ? 'Disconnect'
                  : state.connectionState == BluetoothDeviceState.connecting
                  ? 'Connecting...'
                  : 'Connect'),
              onPressed: state.connectionState == BluetoothDeviceState.connecting
                  ? null
                  : state.connectionState == BluetoothDeviceState.connected
                  ? () => ref.read(deviceProvider(device).notifier).disconnect()
                  : () => ref.read(deviceProvider(device).notifier).connect(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),

            if (state.error != null)
              Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),

            const SizedBox(height: 16),

            // RSSI Graph
            if (state.connectionState == BluetoothDeviceState.connected && state.rssiHistory.isNotEmpty)
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: true),
                    minY: -100,
                    maxY: -40,
                    lineBarsData: [
                      LineChartBarData(
                        spots: state.rssiHistory
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: state.connectionState == BluetoothDeviceState.connecting
                  ? const Center(child: CircularProgressIndicator())
                  : state.services.isEmpty
                  ? const Center(child: Text('Connect to discover services'))
                  : ListView.builder(
                itemCount: state.services.length,
                itemBuilder: (context, i) => ServiceTile(service: state.services[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _batteryColor(int level) {
    if (level > 70) return Colors.green;
    if (level > 30) return Colors.orange;
    return Colors.red;
  }
}