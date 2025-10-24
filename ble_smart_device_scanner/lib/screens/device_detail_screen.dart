import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ble_device.dart';
import '../providers/device_provider.dart';
import '../widgets/service_tile.dart';

class DeviceDetailScreen extends ConsumerStatefulWidget {
  const DeviceDetailScreen({super.key});

  @override
  ConsumerState<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = ModalRoute.of(context)!.settings.arguments as BleDevice?;
    if (device == null) {
      return const Scaffold(body: Center(child: Text('No device selected')));
    }

    final state = ref.watch(deviceProvider(device));
    final colorScheme = Theme.of(context).colorScheme;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    Widget content = SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildDeviceHeaderCard(device, state, colorScheme),
            const SizedBox(height: 16),
            _buildConnectionCard(device, state, colorScheme),
            if (state.error != null) _buildErrorCard(state.error!, colorScheme),
            if (state.connectionState == BluetoothDeviceState.connected && state.rssiHistory.isNotEmpty)
              _buildRssiGraphCard(state, colorScheme),
            Expanded(child: _buildServicesCard(state, colorScheme)),
          ],
        ),
      ),
    );

    return isLargeScreen ? _buildLargeScreenLayout(content, colorScheme) : _buildMobileLayout(content);
  }

  // Layout Builders
  Scaffold _buildLargeScreenLayout(Widget content, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.secondaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              elevation: 24,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.all(24),
              child: Padding(padding: const EdgeInsets.all(32), child: content),
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildMobileLayout(Widget content) {
    return Scaffold(
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: content)),
    );
  }

  // Component Builders
  Widget _buildDeviceHeaderCard(BleDevice device, DeviceState state, ColorScheme colorScheme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _getDeviceGradientColors(state.connectionState, colorScheme)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getDeviceIcon(device), color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${device.id}',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _buildInfoChips(device, state, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoChips(BleDevice device, DeviceState state, ColorScheme colorScheme) {
    final chips = <Widget>[
      _buildInfoChip(Icons.signal_cellular_alt, '${device.rssi} dBm', _getRssiColor(device.rssi), colorScheme),
    ];

    if (state.manufacturerName != null) {
      chips.add(_buildInfoChip(Icons.business, state.manufacturerName!, colorScheme.primary, colorScheme));
    }
    if (state.batteryLevel != null) {
      chips.add(_buildInfoChip(Icons.battery_std, '${state.batteryLevel}%', _batteryColor(state.batteryLevel!), colorScheme));
    }

    return chips;
  }

  Widget _buildConnectionCard(BleDevice device, DeviceState state, ColorScheme colorScheme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildConnectionStatus(state, colorScheme),
            const SizedBox(height: 16),
            _buildConnectionButton(device, state, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(DeviceState state, ColorScheme colorScheme) {
    final statusColor = _getConnectionStatusColor(state.connectionState, colorScheme);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getConnectionIcon(state.connectionState), color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(_getConnectionStatusText(state.connectionState),
            style: TextStyle(fontWeight: FontWeight.w600, color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButton(BleDevice device, DeviceState state, ColorScheme colorScheme) {
    final isConnected = state.connectionState == BluetoothDeviceState.connected;
    final isConnecting = state.connectionState == BluetoothDeviceState.connecting;

    return ElevatedButton.icon(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(isConnected ? Icons.link_off : Icons.link, key: ValueKey(state.connectionState)),
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          isConnected ? 'Disconnect Device' : isConnecting ? 'Connecting...' : 'Connect to Device',
          key: ValueKey(state.connectionState),
        ),
      ),
      onPressed: isConnecting ? null : () => _handleConnection(device, state, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? colorScheme.error : colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  Widget _buildErrorCard(String error, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(error, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildRssiGraphCard(DeviceState state, ColorScheme colorScheme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Signal Strength', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                const Spacer(),
                Text('Current: ${state.rssiHistory.last} dBm',
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: LineChart(LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outline.withOpacity(0.3), strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: -100,
                maxY: -40,
                lineBarsData: [_buildRssiLineData(state, colorScheme)],
              )),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildRssiLineData(DeviceState state, ColorScheme colorScheme) {
    return LineChartBarData(
      spots: state.rssiHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
      isCurved: true,
      color: colorScheme.primary,
      barWidth: 3,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.3), colorScheme.primary.withOpacity(0.1)],
        ),
      ),
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildServicesCard(DeviceState state, ColorScheme colorScheme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildServicesHeader(state, colorScheme),
            const SizedBox(height: 16),
            Expanded(child: _buildServicesContent(state, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesHeader(DeviceState state, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.list_alt, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('Device Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const Spacer(),
        if (state.services.isNotEmpty) _buildServiceCountBadge(state, colorScheme),
      ],
    );
  }

  Widget _buildServiceCountBadge(DeviceState state, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('${state.services.length} services',
          style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildServicesContent(DeviceState state, ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: state.connectionState == BluetoothDeviceState.connecting
          ? _buildLoadingState(colorScheme)
          : state.services.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
        itemCount: state.services.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ServiceTile(service: state.services[i]),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoChip(IconData icon, String label, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary)),
          ),
          const SizedBox(height: 16),
          Text('Discovering Services...', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No Services Found', style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Connect to the device to discover available services',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  void _handleConnection(BleDevice device, DeviceState state, WidgetRef ref) {
    final notifier = ref.read(deviceProvider(device).notifier);
    state.connectionState == BluetoothDeviceState.connected ? notifier.disconnect() : notifier.connect();
  }

  List<Color> _getDeviceGradientColors(BluetoothDeviceState state, ColorScheme colorScheme) {
    return switch (state) {
      BluetoothDeviceState.connected => [Colors.green, Colors.lightGreen],
      BluetoothDeviceState.connecting => [Colors.orange, Colors.amber],
      _ => [colorScheme.primary, colorScheme.primaryContainer],
    };
  }

  IconData _getDeviceIcon(BleDevice device) {
    final name = device.name.toLowerCase();
    if (name.contains('watch')) return Icons.watch;
    if (name.contains('phone')) return Icons.phone_iphone;
    if (name.contains('headphone')) return Icons.headphones;
    return Icons.bluetooth;
  }

  Color _getConnectionStatusColor(BluetoothDeviceState state, ColorScheme colorScheme) {
    return switch (state) {
      BluetoothDeviceState.connected => Colors.green,
      BluetoothDeviceState.connecting => Colors.orange,
      BluetoothDeviceState.disconnecting => Colors.orange,
      _ => colorScheme.onSurface.withOpacity(0.5),
    };
  }

  IconData _getConnectionIcon(BluetoothDeviceState state) {
    return switch (state) {
      BluetoothDeviceState.connected => Icons.check_circle,
      BluetoothDeviceState.connecting => Icons.sync,
      BluetoothDeviceState.disconnecting => Icons.sync,
      _ => Icons.circle,
    };
  }

  String _getConnectionStatusText(BluetoothDeviceState state) {
    return switch (state) {
      BluetoothDeviceState.connected => 'Connected',
      BluetoothDeviceState.connecting => 'Connecting...',
      BluetoothDeviceState.disconnecting => 'Disconnecting...',
      BluetoothDeviceState.disconnected => 'Disconnected',
    };
  }

  Color _getRssiColor(int rssi) => rssi >= -50 ? Colors.green : rssi >= -70 ? Colors.orange : Colors.red;
  Color _batteryColor(int level) => level > 70 ? Colors.green : level > 30 ? Colors.orange : Colors.red;
}