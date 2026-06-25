import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import '../../../data/models/district_model.dart';
import '../widgets/price_card.dart';
import '../widgets/filter_dropdown.dart';
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
  // Temporary state for dropdowns
  String? _tempCrop;
  String? _tempState;
  String? _tempDistrict;
  String? _tempMarket;

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      const filter = Filter();
      ref.read(mandiPricesProvider(filter).notifier).loadNextPage();
    }
  }

  void _applyFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResultsScreen(
          selectedCrop: _tempCrop,
          selectedState: _tempState,
          selectedDistrict: _tempDistrict,
          selectedMarket: _tempMarket,
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _tempCrop = null;
      _tempState = null;
      _tempDistrict = null;
      _tempMarket = null;
    });
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
    const filter = Filter();

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
  final statesAsync = ref.watch(statesProvider);

  final states = statesAsync.value ?? [];

  // Find selected state ID
  StateModel? selectedStateObj;
  if (_tempState != null) {
    try {
      selectedStateObj = states.firstWhere((s) => s.name == _tempState);
    } catch (_) {
      selectedStateObj = null;
    }
  }

  final districtsAsync = ref.watch(
    districtsProvider(
      selectedStateObj?.id,
    ),
  );

  District? selectedDistrictObj;
  if (_tempDistrict != null) {
    districtsAsync.whenData((districts) {
      try {
        selectedDistrictObj = districts.firstWhere(
          (d) => d.name == _tempDistrict,
        );
      } catch (_) {
        selectedDistrictObj = null;
      }
    });
  }

  final marketsAsync =
  ref.watch(
    marketsProvider(
      selectedDistrictObj?.id,
    ),
  );
  final bool hasFilters = _tempCrop != null || 
                          _tempState != null || 
                          _tempDistrict != null || 
                          _tempMarket != null;

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
                value: _tempCrop,
                onChanged: (value) {
                  setState(() {
                    _tempCrop = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: FilterDropdownButton<StateModel>(
                hintText: 'State',
                items: states,
                itemToString: (state) => state.name,
                value: selectedStateObj,
                onChanged: (value) {
                  setState(() {
                    _tempState = value?.name;
                    _tempDistrict = null;
                    _tempMarket = null;
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

                value: _tempDistrict,
                onChanged: (value) {
                  setState(() {
                    _tempDistrict = value;
                    _tempMarket = null;
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
                value: _tempMarket,
                onChanged: (value) {
                  setState(() {
                    _tempMarket = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Buttons updated
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 163, 45),
                // Notice: disabled background/foreground colors are handled automatically
                // by Material when onPressed is null, but you can override them here if needed!
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              // 👇 The magic sauce goes right here 
              onPressed: hasFilters ? _applyFilters : null,
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
              // Optional: You can also disable the Clear button if there are no filters!
              onPressed: hasFilters ? _clearFilters : null, 
              child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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