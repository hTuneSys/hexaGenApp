// SPDX-FileCopyrightText: 2025 hexaTune LLC
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:hexagenapp/src/pages/generation.dart';
import 'package:hexagenapp/src/pages/history.dart';
import 'package:hexagenapp/src/pages/howtouse.dart';
import 'package:hexagenapp/src/pages/products.dart';
import 'package:hexagenapp/src/pages/settings.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:hexagenapp/l10n/app_localizations.dart';

enum MainPageTab { howTo, history, generation, products, settings }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainPageTab _selectedTab = MainPageTab.howTo;
  int _generationItemCount = 0;

  late final List<Widget> _pages = <Widget>[
    const HowToUsePage(),
    const HistoryPage(),
    GenerationPage(
      onItemCountChanged: (count) {
        setState(() => _generationItemCount = count);
      },
    ),
    const ProductsPage(),
    const SettingsPage(),
  ];

  void _onFabPressed() {
    final lang = AppLocalizations.of(context)!;

    if (_selectedTab != MainPageTab.generation) {
      setState(() {
        _selectedTab = MainPageTab.generation;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.generateSignal)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(lang.appName),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Symbols.notifications),
            tooltip: lang.notifications,
            onPressed: () {
              // handle the press
            },
          ),
        ],
      ),
      // enum -> int
      body: IndexedStack(index: _selectedTab.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab.index,
        onDestinationSelected: (int i) {
          if (i == MainPageTab.generation.index) {
            _onFabPressed();
            return;
          }
          setState(() => _selectedTab = MainPageTab.values[i]);
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Symbols.book),
            selectedIcon: const Icon(Symbols.book_rounded, fill: 1),
            tooltip: lang.howToUse,
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.alarm),
            selectedIcon: const Icon(Symbols.alarm_rounded, fill: 1),
            tooltip: lang.history,
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(null, color: Colors.transparent, size: 0),
            selectedIcon: Icon(null, color: Colors.transparent, size: 0),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.store),
            selectedIcon: const Icon(Symbols.store_rounded, fill: 1),
            tooltip: lang.ourProducts,
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Symbols.settings),
            selectedIcon: const Icon(Symbols.settings_rounded, fill: 1),
            tooltip: lang.settings,
            label: '',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: lang.generateSignal,
        child: Icon(_generationItemCount > 0 ? Symbols.autoplay : Symbols.cadence),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
