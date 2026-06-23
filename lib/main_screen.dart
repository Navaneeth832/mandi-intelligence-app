import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/mandi_prices/screens/home_screen.dart';
import 'features/mandi_prices/screens/markets_screen.dart';
import 'features/mandi_prices/widgets/bottom_nav_bar.dart';
import 'features/mandi_prices/providers/filter_selection_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MarketsScreen(),
    const Scaffold(body: Center(child: Text('Alerts Screen'))),
    const Scaffold(body: Center(child: Text('Profile Screen'))),
  ];

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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
