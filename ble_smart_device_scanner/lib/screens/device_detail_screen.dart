import 'package:flutter/material.dart';
import '../models/ble_device.dart';

class DeviceListItem extends StatelessWidget {
  final BleDevice device;

  const DeviceListItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(device.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('ID: ${device.id}\nRSSI: ${device.rssi} dBm'),
        onTap: () => Navigator.pushNamed(context, '/device', arguments: device),
      ),
    );
  }
}