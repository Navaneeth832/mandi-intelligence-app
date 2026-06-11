import 'package:flutter/material.dart';
import '../../../data/models/mandi_price.dart';
import '../widgets/price_card.dart';

class FilterResultsScreen extends StatelessWidget {
  FilterResultsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Results'),
      ),
      body: Column(
        children: [
          _buildActiveFilters(),
          Expanded(
            child: _buildPriceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Chip(
              label: const Text('Crop: Tomato'),
              onDeleted: () {},
            ),
            const SizedBox(width: 8),
            Chip(
              label: const Text('State: Kerala'),
              onDeleted: () {},
            ),
            const SizedBox(width: 8),
            Chip(
              label: const Text('Market: Ernakulam'),
              onDeleted: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _dummyPrices.length + 1, // +1 for the load more button
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _dummyPrices.length) {
          return _buildLoadMoreButton();
        }
        final price = _dummyPrices[index];
        return PriceCard(price: price);
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Handle load more logic
          },
          child: const Text('Load More'),
        ),
      ),
    );
  }
}
