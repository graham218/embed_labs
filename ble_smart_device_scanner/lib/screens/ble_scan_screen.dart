import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/scan_provider.dart';
import '../widgets/device_list_item.dart';

class BleScanScreen extends ConsumerWidget {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final scanNotifier = ref.read(scanProvider.notifier);
    final filteredDevices = scanNotifier.getFilteredDevices();

    final isWide = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3EADCF),
              Color(0xFFABE9CD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Card(
                elevation: 10,
                color: theme.colorScheme.surface.withOpacity(0.9),
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title with icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bluetooth, color: theme.primaryColor, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Nearby Bluetooth Devices',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Filter input
                          ZoomIn(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                labelText: 'Filter by Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                              ),
                              onChanged: scanNotifier.setFilterQuery,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Filter dropdown
                          ZoomIn(
                            child: DropdownButtonFormField<String>(
                              value: scanState.filterType,
                              items: ['All', 'Audio Devices', 'Smartwatches']
                                  .map((type) => DropdownMenuItem(
                                  value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (value) =>
                                  scanNotifier.setFilterType(value ?? 'All'),
                              decoration: InputDecoration(
                                labelText: 'Filter by Type',
                                prefixIcon: const Icon(Icons.filter_alt),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Scan button
                          BounceInDown(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                scanState.isScanning
                                    ? Icons.stop_circle_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 24,
                              ),
                              label: Text(
                                scanState.isScanning ? 'Stop Scanning' : 'Start Scan',
                                style: const TextStyle(fontSize: 16),
                              ),
                              onPressed: scanState.isScanning
                                  ? scanNotifier.stopScan
                                  : scanNotifier.startScan,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 6,
                              ),
                            ),
                          ),

                          if (scanState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                scanState.error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Device list
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: scanState.isScanning
                                  ? const Center(
                                child: CircularProgressIndicator(),
                              )
                                  : filteredDevices.isEmpty
                                  ? FadeIn(
                                child: const Center(
                                  child: Text(
                                    'No devices found',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                                  : constraints.maxWidth > 600
                                  ? GridView.builder(
                                gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  childAspectRatio: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: filteredDevices.length,
                                itemBuilder: (context, index) {
                                  return FadeInUp(
                                    delay: Duration(milliseconds: 50 * index),
                                    child: DeviceListItem(
                                      device: filteredDevices[index],
                                    ),
                                  );
                                },
                              )
                                  : ListView.builder(
                                itemCount: filteredDevices.length,
                                itemBuilder: (context, index) {
                                  return FadeInLeft(
                                    delay: Duration(milliseconds: 40 * index),
                                    child: DeviceListItem(
                                      device: filteredDevices[index],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
