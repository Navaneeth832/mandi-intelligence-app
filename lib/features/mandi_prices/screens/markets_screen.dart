import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/market_directory_model.dart';
import '../../../data/models/state_model.dart';
import '../../../data/models/district_model.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/filter_dropdown.dart';
import 'market_directory_detail_screen.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  StateModel? _selectedState;
  District? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_selectedState == null) return; // Don't load if state not selected

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(marketDirectoryProvider((
            stateId: _selectedState!.id,
            districtId: _selectedDistrict?.id,
            commodityId: null,
            search: _searchQuery
          )).notifier)
          .loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesProvider);
    final districtsAsync = ref.watch(districtsProvider(_selectedState?.id));
    
    final marketsState = _selectedState == null
        ? null
        : ref.watch(marketDirectoryProvider((
            stateId: _selectedState!.id,
            districtId: _selectedDistrict?.id,
            commodityId: null,
            search: _searchQuery
          )));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Directory',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: statesAsync.when(
                          data: (states) => FilterDropdownButton<StateModel>(
                            hintText: 'Select State',
                            items: states,
                            value: _selectedState,
                            itemToString: (s) => s.name,
                            onChanged: (value) {
                              setState(() {
                                _selectedState = value;
                                _selectedDistrict = null;
                              });
                            },
                          ),
                          loading: () => const Text('Loading states...'),
                          error: (_, __) => const Text('Error loading states'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _selectedState == null
                            ? const Text('Select state first')
                            : districtsAsync.when(
                                data: (districts) => FilterDropdownButton<District>(
                                  hintText: 'All Districts',
                                  items: districts,
                                  value: _selectedDistrict,
                                  itemToString: (d) => d.name,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDistrict = value;
                                    });
                                  },
                                ),
                                loading: () => const Text('Loading districts...'),
                                error: (_, __) => const Text('Error loading districts'),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Color(0xFF5F6368)),
                        hintText: 'Search markets...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Market List
            Expanded(
              child: _selectedState == null
    ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.store_mall_directory,
                size: 80,
                color: Color(0xFF14522B),
              ),
              const SizedBox(height: 16),
              const Text(
                'Market Directory',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select a state to browse available markets.\n'
                'You can further filter by district and search for specific markets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      )
                  : marketsState!.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF14522B))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const Center(child: Text('No markets found'));
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          '${state.totalRecords} Markets Found',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index < state.items.length) {
                              final market = state.items[index];
                              return _buildMarketCard(context, market);
                            }
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketCard(BuildContext context, MarketDirectory market) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarketDirectoryDetailScreen(market: market),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.04),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F9EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.store_mall_directory,
                  color: Color(0xFF14522B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Color(0xFF757575)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${market.district}, ${market.state}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF5F6368)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
