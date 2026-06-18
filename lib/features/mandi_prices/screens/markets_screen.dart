import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/filter_dropdown.dart';
import '../../../data/models/district_model.dart';
import '../../../data/models/commodity_model.dart';
import 'market_directory_detail_screen.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  String? _selectedState;
  String? _selectedDistrict;
  Commodity? _selectedCommodity;
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
      final districtsAsync = ref.read(districtsProvider(_selectedState));
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
      ref
          .read(marketDirectoryProvider((
            districtId: selectedDistrictObj?.id,
            commodityId: _selectedCommodity?.id,
          )).notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesProvider);
    final commoditiesAsync = ref.watch(commoditiesProvider);

    final districtsAsync = ref.watch(districtsProvider(_selectedState));

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

    final marketsAsync = ref.watch(marketDirectoryProvider((
      districtId: selectedDistrictObj?.id,
      commodityId: _selectedCommodity?.id,
    )));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Markets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF14522B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilterDropdownButton<String>(
                    hintText: 'State',
                    items: statesAsync.value ?? [],
                    value: _selectedState,
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                        _selectedDistrict = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterDropdownButton<String>(
                    hintText: 'District',
                    items: districtsAsync.maybeWhen(
                      data: (districts) => districts.map((d) => d.name).toList(),
                      orElse: () => [],
                    ),
                    value: _selectedDistrict,
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilterDropdownButton<Commodity>(
              hintText: 'Commodity',
              items: commoditiesAsync.value ?? [],
              itemToString: (c) => c.name,
              value: _selectedCommodity,
              onChanged: (value) {
                setState(() {
                  _selectedCommodity = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: marketsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF14522B))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const Center(child: Text('No markets found.'));
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                              color: Color(0xFF14522B)),
                        ));
                      }
                      final market = state.items[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300)),
                        child: ListTile(
                          title: Text(market.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                Text(' ${market.district}, ${market.state}',
                                    style: const TextStyle(color: Colors.grey)),
                              ]),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MarketDirectoryDetailScreen(market: market)));
                          },
                        ),
                      );
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
}
