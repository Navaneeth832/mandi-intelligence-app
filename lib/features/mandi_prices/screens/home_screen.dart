import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/mandi_price.dart';
import '../widgets/price_card.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/bottom_nav_bar.dart';
import 'filter_results_screen.dart';
import 'market_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCrop = 'Tomato';
  String? _selectedState;
  String? _selectedMarket;

  // Dummy data for dropdowns
  final List<String> _crops = ['Tomato', 'Coconut', 'Paddy'];
  final List<String> _states = ['Kerala', 'Tamil Nadu', 'Karnataka'];
  final List<String> _markets = ['Ernakulam', 'Coimbatore', 'Mangalore'];

  // Dummy data for price cards
  final List<MandiPrice> _dummyPrices = [
    MandiPrice(
      commodity: 'Tomato',
      variety: 'Nadan',
      market: 'Ernakulam',
      district: 'Ernakulam',
      state: 'KL',
      modalPrice: 42,
      highPrice: 45,
      lowPrice: 38,
      priceChange: 1.5,
      lastUpdated: DateTime.now(),
    ),
    MandiPrice(
      commodity: 'Coconut',
      variety: 'West Coast Tall',
      market: 'Alappuzha',
      district: 'Alappuzha',
      state: 'KL',
      modalPrice: 35,
      highPrice: 38,
      lowPrice: 32,
      priceChange: -0.5,
      lastUpdated: DateTime.now(),
    ),
    MandiPrice(
      commodity: 'Paddy',
      variety: 'Uma',
      market: 'Palakkad',
      district: 'Palakkad',
      state: 'KL',
      modalPrice: 28,
      highPrice: 30,
      lowPrice: 26,
      priceChange: 0.2,
      lastUpdated: DateTime.now(),
    ),
  ];

  void _navigateToFilterResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterResultsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildHeroSection(),
        const SizedBox(height: 16),
        _buildLivePricesHeader(),
        const SizedBox(height: 8),
        _buildFilterSection(),
        const SizedBox(height: 16),
        _buildPriceList(),
      ],
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revin Sight',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Icon(Icons.agriculture_outlined, size: 40, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildLivePricesHeader() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Mandi Prices',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            const Chip(
              label: Text('Last updated: 5 mins ago'),
              backgroundColor: Color.fromARGB(255, 224, 224, 224),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FilterDropdownButton(
            hintText: 'Crop',
            items: _crops,
            value: _selectedCrop,
            onChanged: (value) {
              setState(() {
                _selectedCrop = value;
              });
              _navigateToFilterResults();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterDropdownButton(
            hintText: 'State',
            items: _states,
            value: _selectedState,
            onChanged: (value) {
              setState(() {
                _selectedState = value;
              });
              _navigateToFilterResults();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterDropdownButton(
            hintText: 'Market',
            items: _markets,
            value: _selectedMarket,
            onChanged: (value) {
              setState(() {
                _selectedMarket = value;
              });
              _navigateToFilterResults();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dummyPrices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final price = _dummyPrices[index];
        return PriceCard(
          price: price,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketDetailScreen(price: price),
              ),
            );
          },
        );
      },
    );
  }
}
