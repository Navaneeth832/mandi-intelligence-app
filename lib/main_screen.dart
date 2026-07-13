import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/mandi_prices/screens/home_screen.dart';
import 'features/mandi_prices/screens/markets_screen.dart';
import 'features/mandi_prices/widgets/bottom_nav_bar.dart';
import 'features/mandi_prices/providers/filter_selection_provider.dart';
import 'features/forecasts/screens/forecasts_screen.dart';
import 'features/auth/screens/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  Widget _getPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const MarketsScreen();

      case 2:
        return const ForecastsScreen();

      case 3:
        return const ProfileScreen();

      default:
        return const HomeScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(filterSelectionProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
    
    return Scaffold(
      body: _getPage(context, _selectedIndex),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
