import 'package:flutter/material.dart';
import 'screens/ble_scan_screen.dart';
import 'screens/device_detail_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/scan': (context) => const BleScanScreen(),
  '/device': (context) => const DeviceDetailScreen(),
};