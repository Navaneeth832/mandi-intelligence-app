import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/market_directory_model.dart';
import '../../../data/services/mandi_api_service.dart';
import 'filter_results_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class MarketDirectoryDetailScreen extends ConsumerStatefulWidget {
  final MarketDirectory market;

  const MarketDirectoryDetailScreen({super.key, required this.market});

  @override
  ConsumerState<MarketDirectoryDetailScreen> createState() => _MarketDirectoryDetailScreenState();
}

class _MarketDirectoryDetailScreenState extends ConsumerState<MarketDirectoryDetailScreen> {
  late Future<Map<String, dynamic>> _commodityFuture;

  @override
  void initState() {
    super.initState();
    _commodityFuture = _fetchCommodities();
  }

  Future<Map<String, dynamic>> _fetchCommodities() async {
    final response = await http.get(Uri.parse(
        '${MandiApiService.baseUrl}/markets/${widget.market.id}/commodities'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load commodities');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFF111111),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.market.name,
        style: const TextStyle(
          color: Color(0xFF111111),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _commodityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          }

          final data = snapshot.data!;
          final count = data['commodity_count'] as int;
          final commodities =
              (data['commodities'] as List).cast<String>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// MARKET INFO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.marketInformation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.market.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${widget.market.district}, ${widget.market.state}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 163, 45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.availableCommoditiesToday,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// SECTION TITLE
              Text(
                AppLocalizations.of(context)!.todaysCommodities,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 12),

              /// EMPTY STATE
              if (commodities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.noCommoditiesAvailableToday,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

              /// CHIP LIST
              if (commodities.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: commodities
                        .map(
                          (commodity) => InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FilterResultsScreen(
                                    selectedCrop: commodity,
                                    selectedState: widget.market.state,
                                    selectedDistrict: widget.market.district,
                                    selectedMarket: widget.market.name,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFB7E4C7),
                                ),
                              ),
                              child: Text(
                                commodity,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
Widget _buildLoadingState() {
  return const SizedBox(
    height: 400,
    child: Center(
      child: CircularProgressIndicator(
        color: Color(0xFF2E7D32),
      ),
    ),
  );
}

Widget _buildErrorState(BuildContext context, String error) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.red.shade100),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.errorWithDetails(error),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      ],
    ),
  );
}
}
