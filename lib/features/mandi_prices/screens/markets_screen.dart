import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/district_model.dart';
import '../../../data/models/commodity_model.dart';
import 'market_directory_detail_screen.dart';
import '../providers/mandi_prices_provider.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  String _searchQuery = '';
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
      ref
          .read(marketDirectoryProvider((
            districtId: null,
            commodityId: null,
            search: _searchQuery,
          )).notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketDirectoryProvider((
      districtId: null,
      commodityId: null,
      search: _searchQuery,
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
            SearchBar(
              hintText: 'Search by market, district or state...',
              leading: const Icon(Icons.search),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    ]
                  : null,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
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
