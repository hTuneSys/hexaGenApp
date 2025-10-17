// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';

class GenerationPage extends StatefulWidget {
  const GenerationPage({super.key});

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage> {
  bool _manual = false;

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
  }

  void _clearAll() {
    setState(() {
      _sequence.clear();
      _repeatCount = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Frequency • Manual (Switch) ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  lang.manualFrequency,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _manual,
                  onChanged: (v) => setState(() => _manual = v),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --- Slider 0..20 MHz + step buttons ---
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --- Add area + list ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: Text(lang.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lang.listTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                if (_sequence.isEmpty)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.info_outline),
                    title: Text(lang.noItems),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sequence.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final it = _sequence[i];
                      return ListTile(
                        leading: const Icon(Symbols.cadence),
                        title: Text(_fmtHz(it.freqHz)),
                        subtitle: Text(
                          lang.secondsShort(it.seconds.toStringAsFixed(3)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              setState(() => _sequence.removeAt(i)),
                          tooltip: lang.delete,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --- Repeat + Clear All ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          ),
        ),

        const SizedBox(height: 24),
        if (_sequence.isNotEmpty)
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
    );
  }
}

class _SeqItem {
  final double freqHz;
  final double seconds;
  const _SeqItem({required this.freqHz, required this.seconds});
}
