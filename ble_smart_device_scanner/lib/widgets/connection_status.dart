import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionStatus extends StatelessWidget {
  final BluetoothDeviceState state;

  const ConnectionStatus({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String status;
    Color color;
    switch (state) {
      case BluetoothDeviceState.connected:
        status = 'Connected';
        color = Colors.green;
        break;
      case BluetoothDeviceState.connecting:
        status = 'Connecting...';
        color = Colors.blue;
        break;
      case BluetoothDeviceState.disconnecting:
        status = 'Disconnecting...';
        color = Colors.orange;
        break;
      case BluetoothDeviceState.disconnected:
      default:
        status = 'Disconnected';
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}