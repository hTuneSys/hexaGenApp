// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';
import 'package:hexagenapp/src/core/service/storage_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>, int)? onRegenerate;

  const HistoryPage({super.key, this.onRegenerate});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final storageService = StorageServiceProvider.of(context);
    final operations = storageService.getSavedOperations();

    final sortedOperations = operations.reversed.toList();

    if (sortedOperations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              lang.noOperationsYet,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedOperations.length,
      itemBuilder: (context, index) {
        final operation = sortedOperations[index];
        return _OperationCard(
          operation: operation,
          onRegenerate: widget.onRegenerate,
        );
      },
    );
  }
}

class _OperationCard extends StatefulWidget {
  final Map<String, dynamic> operation;
  final Function(List<Map<String, dynamic>>, int)? onRegenerate;

  const _OperationCard({required this.operation, this.onRegenerate});

  @override
  State<_OperationCard> createState() => _OperationCardState();
}

class _OperationCardState extends State<_OperationCard> {
  bool _isExpanded = false;

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(dateTime);
  }

  String _formatTotalDuration(List items) {
    double totalSeconds = 0;
    for (var item in items) {
      totalSeconds += (item['seconds'] as num).toDouble();
    }

    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(1)} s';
    } else if (totalSeconds < 3600) {
      final minutes = (totalSeconds / 60).floor();
      final seconds = (totalSeconds % 60).toStringAsFixed(0);
      return '${minutes}m ${seconds}s';
    } else {
      final hours = (totalSeconds / 3600).floor();
      final minutes = ((totalSeconds % 3600) / 60).floor();
      return '${hours}h ${minutes}m';
    }
  }

  String _formatFrequency(int freqHz) {
    if (freqHz >= 1000000) {
      return '${(freqHz / 1000000).toStringAsFixed(3)} MHz';
    } else if (freqHz >= 1000) {
      return '${(freqHz / 1000).toStringAsFixed(2)} kHz';
    } else {
      return '$freqHz Hz';
    }
  }

  void _handleRegenerate() {
    final items = widget.operation['items'] as List;
    final repeatCount = widget.operation['repeatCount'] as int;

    final itemsList = items.map((item) {
      return {
        'freqHz': item['freqHz'] as int,
        'seconds': (item['seconds'] as num).toDouble(),
      };
    }).toList();

    widget.onRegenerate?.call(itemsList, repeatCount);

    final lang = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(lang.operationRegenerated)));
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final items = widget.operation['items'] as List;
    final repeatCount = widget.operation['repeatCount'] as int;
    final timestamp = widget.operation['timestamp'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDateTime(timestamp),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _handleRegenerate,
                        tooltip: lang.regenerate,
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang.totalItemsCount(items.length),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (repeatCount > 1)
                        Text(
                          lang.repeatCount(repeatCount),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.totalDuration(_formatTotalDuration(items)),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final freqHz = item['freqHz'] as int;
                  final seconds = (item['seconds'] as num).toDouble();

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    title: Text(
                      '${lang.frequency}: ${_formatFrequency(freqHz)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      '${lang.duration}: ${seconds.toStringAsFixed(2)} s',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
