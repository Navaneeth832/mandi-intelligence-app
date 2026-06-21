import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/market_directory_model.dart';
import '../providers/mandi_prices_provider.dart';
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
  int? _selectedStateId;
  int? _selectedDistrictId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_selectedStateId == null) return; // Don't load if state not selected

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(marketDirectoryProvider((
            stateId: _selectedStateId,
            districtId: _selectedDistrictId,
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
    final districtsAsync = ref.watch(districtsProvider(_selectedStateId));
    
    final marketsState = _selectedStateId == null
        ? null
        : ref.watch(marketDirectoryProvider((
            stateId: _selectedStateId,
            districtId: _selectedDistrictId,
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
                          data: (states) => DropdownButtonFormField<int>(
                            value: _selectedStateId,
                            hint: const Text('Select State'),
                            isExpanded: true,
                            items: states.map((state) => DropdownMenuItem(
                              value: state.id,
                              child: Text(state.name),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStateId = value;
                                _selectedDistrictId = null;
                              });
                            },
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading states'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _selectedStateId == null
                            ? const Text('Select state first')
                            : districtsAsync.when(
                                data: (districts) => DropdownButtonFormField<int>(
                                  value: _selectedDistrictId,
                                  hint: const Text('Select District'),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('All Districts')),
                                    ...districts.map((d) => DropdownMenuItem(
                                      value: d.id,
                                      child: Text(d.name),
                                    ))
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDistrictId = value;
                                    });
                                  },
                                ),
                                loading: () => const CircularProgressIndicator(),
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
              child: _selectedStateId == null
                  ? const Center(child: Text('Please select a state to see markets'))
                  : marketsState!.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF14522B))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const Center(child: Text('No markets found'));
                  }
                  return ListView.separated(
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
