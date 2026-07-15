import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_model.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import 'market_detail_screen.dart';
import '../widgets/price_card.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class FilterResultsScreen extends ConsumerStatefulWidget {
  final String? selectedCrop;
  final String? selectedState;
  final String? selectedDistrict;
  final String? selectedMarket;

  const FilterResultsScreen({
    super.key,
    this.selectedCrop,
    this.selectedState,
    this.selectedDistrict,
    this.selectedMarket,
  });

  @override
  ConsumerState<FilterResultsScreen> createState() =>
      _FilterResultsScreenState();
}

class _FilterResultsScreenState extends ConsumerState<FilterResultsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filter = Filter(
        crop: widget.selectedCrop,
        state: widget.selectedState,
        district: widget.selectedDistrict,
        market: widget.selectedMarket,
      );
      ref.read(mandiPricesProvider(filter).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = Filter(
      crop: widget.selectedCrop,
      state: widget.selectedState,
      district: widget.selectedDistrict,
      market: widget.selectedMarket,
    );
    final filteredPricesAsync = ref.watch(mandiPricesProvider(filter));
    final activeFilters = {
      'crop': widget.selectedCrop,
      'state': widget.selectedState,
      'district': widget.selectedDistrict,
      'market': widget.selectedMarket,
    };
    final activeFiltersList =
        activeFilters.entries.where((e) => e.value != null).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.filterResults,
          style: TextStyle(
            color: Color.fromARGB(255, 39, 163, 45),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Color(0xFF111111)),
            onPressed: () {},
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1),
        ),
      ),
      body: Column(
        children: [
          _buildActiveFiltersSection(context, activeFiltersList),
          Expanded(
            child: filteredPricesAsync.when(
              data: (state) {
                if (state.items.isEmpty) {
                  return const EmptyStateWidget();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.resultsFound(state.totalRecords),
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildPriceList(state),
                    ),
                  ],
                );
              },
              loading: () => const LoadingWidget(),
              error: (err, stack) => ErrorStateWidget(
                errorMessage: err.toString(),
                onRetry: () => ref
                    .read(mandiPricesProvider(filter).notifier)
                    .loadInitialPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSection(
    BuildContext context,
    List<MapEntry<String, String?>> activeFiltersList,
  ) {
    if (activeFiltersList.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.activeFilters(activeFiltersList.length),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // This pops all screens until it hits the very first one (your root screen)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  AppLocalizations.of(context)!.clearAll,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 39, 163, 45),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: activeFiltersList.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFDCDFE4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.value!,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          String? crop = widget.selectedCrop;
                          String? state = widget.selectedState;
                          String? district = widget.selectedDistrict;
                          String? market = widget.selectedMarket;

                          // 1. Remove the selected filter
                          switch (entry.key) {
                            case 'crop':
                              crop = null;
                              break;
                            case 'state':
                              state = null;
                              district = null; // Clear dependent too
                              market = null;
                              break;
                            case 'district':
                              district = null;
                              market = null;
                              break;
                            case 'market':
                              market = null;
                              break;
                          }

                          // 2. CHECK IF ALL FILTERS ARE NOW GONE
                          if (crop == null &&
                              state == null &&
                              district == null &&
                              market == null) {
                            // If no filters are left, pop back to the Home Screen with the navbar! 🚀
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          } else {
                            // If some filters still remain, just reload this screen with the updated filters
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FilterResultsScreen(
                                  selectedCrop: crop,
                                  selectedState: state,
                                  selectedDistrict: district,
                                  selectedMarket: market,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceList(MandiPricesState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < state.items.length) {
          final price = state.items[index];
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
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 39, 163, 45),
              ),
            ),
          );
        }
      },
    );
  }
}
