import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/market_comparison_model.dart';
import '../providers/market_comparison_provider.dart';

class MarketComparisonScreen extends ConsumerStatefulWidget {
  final String commodityName;
  final String currentMarketName;
  final int? commodityId;

  const MarketComparisonScreen({
    super.key,
    required this.commodityName,
    required this.currentMarketName,
    this.commodityId,
  });

  @override
  ConsumerState<MarketComparisonScreen> createState() => _MarketComparisonScreenState();
}

class _MarketComparisonScreenState extends ConsumerState<MarketComparisonScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(marketComparisonProvider.notifier).fetchComparison(
            commodityId: widget.commodityId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketComparisonProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Warm cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compare Nearby Mandis',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${widget.commodityName} • Near ${widget.currentMarketName}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls Bar (Location & Quantity)
            _buildTopControlsCard(context, state),

            // Sort Option Chips
            _buildSortOptionChips(state),

            // Mandi Cards List / Loader / Error
            Expanded(
              child: _buildMandiList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControlsCard(BuildContext context, MarketComparisonState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE0CC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFFF97316)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR LOCATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      state.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showLocationDialog(context),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 16, color: Color(0xFFF97316)),
                label: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF3F4F6)),

          // Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.scale_outlined, size: 18, color: Color(0xFF6B7280)),
                  SizedBox(width: 8),
                  Text(
                    'Sell Quantity:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (state.quantity > 1) {
                          ref
                              .read(marketComparisonProvider.notifier)
                              .updateQuantity(state.quantity - 1, widget.commodityId);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${state.quantity.toStringAsFixed(0)} Quintals',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        ref
                            .read(marketComparisonProvider.notifier)
                            .updateQuantity(state.quantity + 1, widget.commodityId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: const Color(0xFFF97316)),
      ),
    );
  }

  Widget _buildSortOptionChips(MarketComparisonState state) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: MarketSortOption.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = MarketSortOption.values[index];
          final isSelected = state.sortOption == option;

          return ChoiceChip(
            label: Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFFF97316),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
            ),
            elevation: isSelected ? 2 : 0,
            onSelected: (selected) {
              if (selected) {
                ref.read(marketComparisonProvider.notifier).setSortOption(option);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMandiList(MarketComparisonState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF97316)),
            SizedBox(height: 16),
            Text(
              'Computing distance matrix & net payouts...',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(marketComparisonProvider.notifier).fetchComparison(
                        commodityId: widget.commodityId,
                      );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.sortedMarkets.isEmpty) {
      return const Center(
        child: Text(
          'No nearby mandis found for this commodity.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sortedMarkets.length,
      itemBuilder: (context, index) {
        final item = state.sortedMarkets[index];
        return _buildMandiCard(item, state.quantity);
      },
    );
  }

  Widget _buildMandiCard(MarketComparisonItem item, double quantity) {
    final isBest = item.isBestValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBest ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
          width: isBest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isBest
                ? const Color(0xFFF97316).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: isBest ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best Value Badge Header (if true)
          if (isBest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'BEST VALUE — Highest Net Payout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mandi Name & Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.marketName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.districtName}, ${item.stateName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.near_me_rounded, size: 13, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            '${item.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Financial Metrics Breakdown Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow(
                        label: 'Selling Price (per qtl)',
                        value: _currencyFormat.format(item.sellingPrice),
                        valueColor: const Color(0xFF1F2937),
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        label: 'Transport Cost',
                        value: '- ${_currencyFormat.format(item.transportCost)} /qtl',
                        valueColor: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 6),
                      _buildMetricRow(
                        label: 'Mandi Fee (1%)',
                        value: '- ${_currencyFormat.format(item.mandiCommission)} /qtl',
                        valueColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Net Profit Highlight Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isBest ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isBest ? const Color(0xFF10B981) : const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NET PROFIT (PER QTL)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isBest ? const Color(0xFF047857) : const Color(0xFF065F46),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _currencyFormat.format(item.netProfit),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isBest ? const Color(0xFF047857) : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL (${quantity.toStringAsFixed(0)} QTL)',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            _currencyFormat.format(item.totalNetProfit),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showLocationDialog(BuildContext context) {
    final latController = TextEditingController(text: '9.5916');
    final lngController = TextEditingController(text: '76.5222');
    final labelController = TextEditingController(text: 'Kottayam, Kerala');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Custom Coordinates / Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g. Kottayam, Kerala',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final lat = double.tryParse(latController.text) ?? 9.5916;
                  final lng = double.tryParse(lngController.text) ?? 76.5222;
                  final label = labelController.text.isNotEmpty ? labelController.text : 'Custom Location';

                  ref.read(marketComparisonProvider.notifier).setCustomLocation(
                        lat: lat,
                        lng: lng,
                        label: label,
                        commodityId: widget.commodityId,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Apply Location', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
