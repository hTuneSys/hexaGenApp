// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
import 'package:hexagenapp/src/core/service/device_service.dart';
import 'package:hexagenapp/src/core/service/storage_service.dart';
import 'package:hexagenapp/src/core/service/log_service.dart';
import 'package:hexagenapp/src/core/error/error.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _logScrollController = ScrollController();
  bool _autoScroll = true;
  LogLevel? _minLogLevel;

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _logScrollController.hasClients) {
      _logScrollController.animateTo(
        _logScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceService = DeviceServiceProvider.of(context);
    final storageService = StorageServiceProvider.of(context);
    final lang = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: Listenable.merge([deviceService, storageService, logger]),
      builder: (context, _) {
        if (!deviceService.isInitialized || !storageService.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        // Scroll to bottom when logs update
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return RefreshIndicator(
          onRefresh: deviceService.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildTopCard(context, lang, storageService, deviceService),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: _buildLogMonitorCard(context, lang),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildTopCard(
    BuildContext context,
    AppLocalizations lang,
    StorageService storageService,
    DeviceService deviceService,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme section
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  lang.themeMode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'system',
                    label: Text(lang.themeSystem),
                    icon: const Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: 'light',
                    label: Text(lang.themeLight),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: 'dark',
                    label: Text(lang.themeDark),
                    icon: const Icon(Icons.dark_mode),
                  ),
                ],
                selected: {storageService.themeMode},
                onSelectionChanged: (Set<String> selected) {
                  storageService.setThemeMode(selected.first);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Device section
            deviceService.currentDevice == null
                ? _buildNoDeviceContent(context, lang)
                : _buildDeviceContent(context, lang, deviceService),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDeviceContent(BuildContext context, AppLocalizations lang) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.usb_off,
              size: 32,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 16),
            Text(
              lang.deviceNoDeviceConnected,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          lang.devicePleaseConnect,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeviceContent(
    BuildContext context,
    AppLocalizations lang,
    DeviceService deviceService,
  ) {
    final device = deviceService.currentDevice!;
    final deviceName = device.name;
    // ignore: unnecessary_null_comparison
    final name = (deviceName == null || deviceName.trim().isEmpty) ? 'hexaTune' : deviceName;

    final nameParts = name.split(' ');
    final brand = nameParts.isNotEmpty ? nameParts[0] : 'hexaTune';
    final model = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.usb,
          size: 24,
          color: deviceService.isConnected ? colorScheme.primary : colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                brand,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (model.isNotEmpty)
                Text(
                  model,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (deviceService.waitingForResponse)
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          )
        else if (deviceService.deviceVersion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deviceService.deviceVersion!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else if (deviceService.deviceError != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deviceService.deviceError!.code,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildLogMonitorCard(BuildContext context, AppLocalizations lang) {
    final logs = logger.getRecentLogs(count: 100, minLevel: _minLogLevel);

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                const Text('Debug'),
                Switch(
                  value: logger.debugMode,
                  onChanged: (value) => logger.debugMode = value,
                ),
                const SizedBox(width: 8),
                const Text('Auto Scroll'),
                Switch(
                  value: _autoScroll,
                  onChanged: (value) => setState(() => _autoScroll = value),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => logger.clearHistory(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<LogLevel?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('All')),
                  ButtonSegment(value: LogLevel.info, label: Text('Info+')),
                  ButtonSegment(value: LogLevel.warning, label: Text('Warn+')),
                  ButtonSegment(value: LogLevel.error, label: Text('Error+')),
                ],
                selected: {_minLogLevel},
                onSelectionChanged: (Set<LogLevel?> selected) {
                  setState(() => _minLogLevel = selected.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _logScrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            log.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: _getLogColor(context, log.level),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20), // Space for FAB
          ],
        ),
      ),
    );
  }

  Color _getLogColor(BuildContext context, LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.white;
      case LogLevel.warning:
        return Colors.yellow;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red;
    }
  }


}
