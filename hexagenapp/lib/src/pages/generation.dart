// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';

class GenerationPage extends StatefulWidget {
  final ValueChanged<int>? onItemCountChanged;

  const GenerationPage({super.key, this.onItemCountChanged});

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage> {
  static const int _maxItems = 64;

  // 0 Hz .. 20 MHz
  static const double _minHz = 0;
  static const double _maxHz = 20_000_000;
  double _sliderHz = 1_000_000;

  final TextEditingController _secondsCtrl = TextEditingController(text: '1.0');
  final List<_SeqItem> _sequence = <_SeqItem>[];
  int _repeatCount = 1;

  @override
  void dispose() {
    _secondsCtrl.dispose();
    super.dispose();
  }

  String _fmtHz(double hz) {
    if (hz >= 1_000_000) {
      return '${(hz / 1_000_000).toStringAsFixed(2)} MHz';
    } else if (hz >= 1_000) {
      return '${(hz / 1_000).toStringAsFixed(1)} kHz';
    }
    return '${hz.toStringAsFixed(0)} Hz';
  }

  void _addItem() {
    final lang = AppLocalizations.of(context)!;

    if (_sequence.length >= _maxItems) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(lang.maxItemsReached)));
      return;
    }

    final secStr = _secondsCtrl.text.trim();
    final sec = double.tryParse(secStr);
    if (sec == null || sec <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(lang.secondsPositiveError)));
      return;
    }
    setState(() {
      _sequence.add(_SeqItem(freqHz: _sliderHz, seconds: sec));
    });
    widget.onItemCountChanged?.call(_sequence.length);
  }

  void _clearAll() {
    setState(() {
      _sequence.clear();
      _repeatCount = 1;
    });
    widget.onItemCountChanged?.call(_sequence.length);
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Column(
      children: [
        // --- Fixed top: Slider + Add frequency ---
        Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.selectedFrequency(_fmtHz(_sliderHz))),
                Slider(
                  min: _minHz,
                  max: _maxHz,
                  value: _sliderHz.clamp(_minHz, _maxHz),
                  divisions: 200,
                  label: _fmtHz(_sliderHz),
                  onChanged: (v) => setState(() => _sliderHz = v),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _sliderHz = (_sliderHz - 10_000).clamp(_minHz, _maxHz);
                      }),
                      child: Text(lang.stepMinus10kHz),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _sliderHz = (_sliderHz + 10_000).clamp(_minHz, _maxHz);
                      }),
                      child: Text(lang.stepPlus10kHz),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _sliderHz = (_sliderHz + 1_000_000).clamp(
                          _minHz,
                          _maxHz,
                        );
                      }),
                      child: Text(lang.stepPlus1MHz),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _secondsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]+[.]?[0-9]*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: lang.secondsLabel,
                          hintText: lang.secondsHint,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _sequence.length >= _maxItems
                          ? null
                          : _addItem,
                      icon: const Icon(Icons.add),
                      label: Text(lang.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // --- Scrollable middle: List ---
        Expanded(
          child: _sequence.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang.noItems,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: _sequence.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _sequence.removeAt(oldIndex);
                      _sequence.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, i) {
                    final it = _sequence[i];
                    return ListTile(
                      key: ValueKey('${it.freqHz}_${it.seconds}_$i'),
                      leading: const Icon(Symbols.cadence),
                      title: Text(_fmtHz(it.freqHz)),
                      subtitle: Text(
                        lang.secondsShort(it.seconds.toStringAsFixed(3)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => _sequence.removeAt(i));
                          widget.onItemCountChanged?.call(_sequence.length);
                        },
                        tooltip: lang.delete,
                      ),
                    );
                  },
                ),
        ),

        // --- Fixed bottom: Repeat controls ---
        Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      lang.repeat,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(
                      onPressed: _repeatCount > 1
                          ? () => setState(() => _repeatCount--)
                          : null,
                      icon: const Icon(Icons.remove),
                      tooltip: lang.decrease,
                    ),
                    SizedBox(
                      width: 72,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: TextEditingController(
                          text: _repeatCount.toString(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (v) {
                          final n = int.tryParse(v);
                          if (n == null || n < 1) return;
                          setState(() => _repeatCount = n);
                        },
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _repeatCount++),
                      icon: const Icon(Icons.add),
                      tooltip: lang.increase,
                    ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: _sequence.isNotEmpty ? _clearAll : null,
                      child: Text(lang.clearAll),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.totalItems(_sequence.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      lang.repeatCount(_repeatCount),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeqItem {
  final double freqHz;
  final double seconds;
  const _SeqItem({required this.freqHz, required this.seconds});
}
