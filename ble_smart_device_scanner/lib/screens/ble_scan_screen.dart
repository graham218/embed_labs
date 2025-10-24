import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scan_provider.dart';
import '../widgets/device_list_item.dart';

class BleScanScreen extends ConsumerWidget {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final scanNotifier = ref.read(scanProvider.notifier);
    final filteredDevices = scanNotifier.getFilteredDevices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Filter by Name',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  onChanged: scanNotifier.setFilterQuery,
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: scanState.filterType,
                  isExpanded: true,
                  items: ['All', 'Audio Devices', 'Smartwatches']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => scanNotifier.setFilterType(value ?? 'All'),
                  hint: const Text('Filter by Type'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(scanState.isScanning ? Icons.stop : Icons.play_arrow),
                  label: Text(scanState.isScanning ? 'Stop Scan' : 'Start Scan'),
                  onPressed: scanState.isScanning ? scanNotifier.stopScan : scanNotifier.startScan,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (scanState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      scanState.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: scanState.isScanning
                      ? const Center(child: CircularProgressIndicator())
                      : filteredDevices.isEmpty
                      ? const Center(child: Text('No devices found'))
                      : constraints.maxWidth > 600
                      ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      return DeviceListItem(device: filteredDevices[index]);
                    },
                  )
                      : ListView.builder(
                    itemCount: filteredDevices.length,
                    itemBuilder: (context, index) {
                      return DeviceListItem(device: filteredDevices[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}