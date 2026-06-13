import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/mandi_price.dart';
import '../widgets/price_card.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/bottom_nav_bar.dart';
import 'filter_results_screen.dart';
import 'market_detail_screen.dart';
import '../providers/filter_model.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCrop;
  String? _selectedState;
  String? _selectedMarket;
  

  void _navigateToFilterResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResultsScreen(
          selectedCrop: _selectedCrop,
          selectedState: _selectedState,
          selectedMarket: _selectedMarket,
        ),
      ),
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
  final cropsAsync = ref.watch(commoditiesProvider);
  final statesAsync = ref.watch(statesProvider);
  final marketsAsync = ref.watch(marketsProvider);
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FilterDropdownButton(
              hintText: 'Crop',
              items: cropsAsync.value ?? [],
              value: _selectedCrop,
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilterDropdownButton(
              hintText: 'State',
              items: statesAsync.value ?? [],
              value: _selectedState,
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilterDropdownButton(
              hintText: 'Market',
              items: marketsAsync.value ?? [],
              value: _selectedMarket,
              onChanged: (value) {
                setState(() {
                  _selectedMarket = value;
                });
              },
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _navigateToFilterResults,
              child: const Text('Apply Filters'),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCrop = null;
                  _selectedState = null;
                  _selectedMarket = null;
                });
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildPriceList() {
    final filter = Filter(
      crop: _selectedCrop,
      state: _selectedState,
      market: _selectedMarket,
    );

    final pricesAsync = ref.watch(
      mandiPricesProvider(filter),
    );

    return pricesAsync.when(
      data: (prices) {
        if (prices.isEmpty) {
          return const EmptyStateWidget();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prices.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final price = prices[index];

            return PriceCard(
              price: price,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MarketDetailScreen(
                      price: price,
                    ),
                  ),
                );
              },
            );
          },
        );
      },

      loading: () => const LoadingWidget(),

      error: (err, stack) => ErrorStateWidget(
        errorMessage: err.toString(),
        onRetry: () {
          ref.refresh(
            mandiPricesProvider(filter),
          );
        },
      ),
    );
  }
}
