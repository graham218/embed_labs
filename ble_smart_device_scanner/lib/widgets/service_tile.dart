import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceTile extends StatelessWidget {
  final BluetoothService service;

  const ServiceTile({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Text('Service: ${service.serviceUuid.toString()}'),
        children: service.characteristics
            .map(
              (c) => ListTile(
            title: Text(c.characteristicUuid.toString()),
            subtitle: Text(
              'Properties: ${c.properties.read ? "Read " : ""}${c.properties.write ? "Write " : ""}${c.properties.notify ? "Notify" : ""}',
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}