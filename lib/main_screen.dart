import 'package:flutter/material.dart';
import 'features/mandi_prices/screens/home_screen.dart';
import 'features/mandi_prices/screens/markets_screen.dart';
import 'features/mandi_prices/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
