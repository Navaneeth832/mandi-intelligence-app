import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/models/district_model.dart';
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
import '../providers/filter_selection_provider.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCrop;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedMarket;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Listen for filter updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final filter = ref.read(filterSelectionProvider);
       if (filter != null) {
        setState(() {
          _selectedCrop = filter.crop;
          _selectedState = filter.state;
          _selectedDistrict = filter.district;
          _selectedMarket = filter.market;
        });
        ref.read(filterSelectionProvider.notifier).state = null;
       }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final filter = Filter(
        crop: _selectedCrop,
        state: _selectedState,
        district: _selectedDistrict,
        market: _selectedMarket,
      );
      ref.read(mandiPricesProvider(filter).notifier).loadNextPage();
    }
  }

  void _navigateToFilterResults() {
    if (_selectedCrop == null &&
      _selectedState == null &&
      _selectedDistrict == null &&
      _selectedMarket == null) {
    return;
  }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResultsScreen(
          selectedCrop: _selectedCrop,
          selectedState: _selectedState,
          selectedDistrict: _selectedDistrict,
          selectedMarket: _selectedMarket,
        ),
      ),
    );
  }
  String getRelativeTime(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Light grey background matching the design
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.agriculture_outlined, color: Color.fromARGB(255, 39, 163, 45), size: 32),
            SizedBox(width: 8),
            Text(
              '',
              style: TextStyle(
                color: Color.fromARGB(255, 26, 152, 9),
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Color.fromARGB(255, 39, 163, 45), size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

 Widget _buildBody() {
    final filter = Filter(
      crop: _selectedCrop,
      state: _selectedState,
      district: _selectedDistrict,
      market: _selectedMarket,
    );

    final pricesAsync = ref.watch(mandiPricesProvider(filter));
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the current filter
        ref.invalidate(mandiPricesProvider(filter));
        ref.invalidate(statesProvider);
        ref.invalidate(commoditiesProvider);
        ref.invalidate(marketsProvider);

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        children: [
          _buildHeaderSection(
              pricesAsync.maybeWhen(
                data: (state) =>
                    state.items.isNotEmpty
                        ? state.items.first.createdAt
                        : DateTime.now(),
                orElse: () => DateTime.now(),
              ),
            ),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 20),
          _buildPriceList(filter),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(DateTime latestUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.hexagon, color: Color.fromARGB(255, 39, 163, 45), size: 68),
                Icon(Icons.arrow_upward, color: Colors.white, size: 32),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Mandi Prices',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()), 
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                'Last updated: ${getRelativeTime(latestUpdate)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
Widget _buildFilterSection() {
  final cropsAsync = ref.watch(commodityListProvider);
  // ...

    final statesAsync = ref.watch(statesProvider);
    
    // Find selected state ID to pass to districtsProvider
    final selectedStateObj = statesAsync.value?.firstWhere(
      (s) => s.name == _selectedState,
      orElse: () => StateModel(id: -1, name: ''),
    );
    
    final districtsAsync = ref.watch(
      districtsProvider(
        selectedStateObj?.id != -1 ? selectedStateObj?.id : null,
      ),
    );
    District? selectedDistrictObj;

    districtsAsync.whenData((districts) {
      try {
        selectedDistrictObj = districts.firstWhere(
          (d) => d.name == _selectedDistrict,
        );
      } catch (_) {
        selectedDistrictObj = null;
      }
    });

    final marketsAsync =
    ref.watch(
      marketsProvider(
        selectedDistrictObj?.id,
      ),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: FilterDropdownButton<String>(
                  hintText: 'Commodity',
                  items: cropsAsync.value ?? [],
                  value: _selectedCrop,
                  onChanged: (value) {
                    setState(() {
                      _selectedCrop = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: FilterDropdownButton<StateModel>(
                  hintText: 'State',
                  items: statesAsync.value ?? [],
                  itemToString: (state) => state.name,
                  value: _selectedState == null
                    ? null
                    : statesAsync.value?.firstWhere(
                        (s) => s.name == _selectedState,
                      ),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value?.name;
                      _selectedDistrict = null;
                      _selectedMarket = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              SizedBox(
                width: 160,
                child: FilterDropdownButton<String>(
                  hintText: 'District',
                  items: districtsAsync.maybeWhen(
                    data: (districts) =>
                        districts
                            .map((d) => d.name)
                            .toList(),
                    orElse: () => [],
                  ),

                  value: _selectedDistrict,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedMarket = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: FilterDropdownButton<String>(
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
        ),
        const SizedBox(height: 16),
        // Buttons retained to keep your logic unbroken, styled to vibe with the UI
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 39, 163, 45),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _navigateToFilterResults,
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 39, 163, 45),
                  side: const BorderSide(color: Color.fromARGB(255, 39, 163, 45), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _selectedCrop = null;
                    _selectedState = null;
                    _selectedDistrict = null;
                    _selectedMarket = null;
                  });
                },
                child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceList(Filter filter) {
    final pricesAsync = ref.watch(mandiPricesProvider(filter));

    return pricesAsync.when(
      data: (state) {
        if (state.items.isEmpty) {
          return const EmptyStateWidget();
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final price = state.items[index];

                return PriceCard(
                  price: price,
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketDetailScreen(
                          price: price,
                        ),
                      ),
                    );
                                       },
                );
              },
            ),
            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 39, 163, 45),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (err, stack) => ErrorStateWidget(
        errorMessage: err.toString(),
        onRetry: () {
          ref.read(mandiPricesProvider(filter).notifier).loadInitialPage();
        },
      ),
    );
  }
}