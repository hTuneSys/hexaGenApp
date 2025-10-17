// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    return Center(child: Text(lang.howToUse));
  }
}
