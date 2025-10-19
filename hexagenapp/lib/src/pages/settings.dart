// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
import 'package:hexagenapp/src/core/service/device_service.dart';
import 'package:hexagenapp/src/core/service/storage_service.dart';
import 'package:hexagenapp/src/core/error/error.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceService = DeviceServiceProvider.of(context);
    final storageService = StorageServiceProvider.of(context);
    final lang = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: Listenable.merge([deviceService, storageService]),
      builder: (context, _) {
        if (!deviceService.isInitialized || !storageService.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: deviceService.refresh,
          child: ListView(
            children: [
              _buildThemeCard(context, lang, storageService),
              deviceService.currentDevice == null
                  ? _buildNoDeviceCard(context, lang)
                  : _buildDeviceCard(context, lang, deviceService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppLocalizations lang,
    StorageService storageService,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
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
          ],
        ),
      ),
    );
  }

  Widget _buildNoDeviceCard(BuildContext context, AppLocalizations lang) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.usb_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              lang.deviceNoDeviceConnected,
              style: Theme.of(context).textTheme.titleLarge,
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
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    AppLocalizations lang,
    DeviceService deviceService,
  ) {
    final device = deviceService.currentDevice!;
    final deviceName = device.name;
    // ignore: unnecessary_null_comparison
    final name = (deviceName == null || deviceName.trim().isEmpty)
        ? 'hexaTune'
        : deviceName;

    final nameParts = name.split(' ');
    final brand = nameParts.isNotEmpty ? nameParts[0] : 'hexaTune';
    final model = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(
              Icons.usb,
              size: 48,
              color: deviceService.isConnected
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brand,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (model.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(model, style: Theme.of(context).textTheme.titleMedium),
                  ],
                  const SizedBox(height: 12),
                  if (deviceService.waitingForResponse)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.deviceQueryingVersion,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    )
                  else if (deviceService.deviceVersion != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang.deviceVersion(deviceService.deviceVersion!),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else if (deviceService.deviceError != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang.deviceError(
                          deviceService.deviceError!.getLocalizedMessage(lang),
                          deviceService.deviceError!.code,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
