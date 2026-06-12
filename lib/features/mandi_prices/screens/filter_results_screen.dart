import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_model.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/price_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import 'market_detail_screen.dart';

class FilterResultsScreen extends ConsumerWidget {
  final String? selectedCrop;
  final String? selectedState;
  final String? selectedMarket;

  const FilterResultsScreen({
    super.key,
    this.selectedCrop,
    this.selectedState,
    this.selectedMarket,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = Filter(
      crop: selectedCrop,
      state: selectedState,
      market: selectedMarket,
    );
    final filteredPricesAsync = ref.watch(mandiPricesProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Results'),
      ),
      body: Column(
        children: [
          _buildActiveFilters(),
          Expanded(
            child: filteredPricesAsync.when(
              data: (prices) {
                if (prices.isEmpty) {
                  return const EmptyStateWidget();
                }
                return _buildPriceList(prices);
              },
              loading: () => const LoadingWidget(),
              error: (err, stack) => ErrorStateWidget(
                errorMessage: err.toString(),
                onRetry: () => ref.refresh(mandiPricesProvider(filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final filters = <String, String?>{
      'Crop': selectedCrop,
      'State': selectedState,
      'Market': selectedMarket,
    };

    final activeFilters = <Widget>[];
    filters.forEach((key, value) {
      if (value != null) {
        activeFilters.add(
          Chip(
            label: Text('$key: $value'),
          ),
        );
        activeFilters.add(const SizedBox(width: 8));
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: activeFilters,
        ),
      ),
    );
  }

  Widget _buildPriceList(List<dynamic> prices) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: prices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final price = prices[index];
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