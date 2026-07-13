import 'package:flutter/material.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: const Color(0xFF8EFF8E), // Bright light green pill highlight
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF111111),
            );
          }
          return const TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w500, 
            color: Color(0xFF444444),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF0A4A1C), size: 26);
          }
          return const IconThemeData(color: Color(0xFF222222), size: 26);
        }),
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFFEFEFEF), // Light grey matching design image_0aa080.png
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: AppLocalizations.of(context)!.markets,
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: AppLocalizations.of(context)!.forecasts,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}
