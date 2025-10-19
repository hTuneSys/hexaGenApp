// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24.0),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                lang.comingSoon,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                lang.comingSoonMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
