import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/mandi_price.dart';
import '../../../data/models/price_history.dart';
import '../../../data/repositories/mandi_repository.dart';
import '../../../data/services/mandi_api_service.dart';

class MarketDetailScreen extends StatefulWidget {
  final MandiPrice price;

  const MarketDetailScreen({super.key, required this.price});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  late Future<List<PriceHistory>> _historyFuture;
  final MandiRepository _repository = MandiRepository(MandiApiService());

  @override
  void initState() {
    super.initState();
    _historyFuture = _repository.getPriceHistory(
      commodity: widget.price.commodity,
      market: widget.price.market,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF111111), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.price.commodity,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF111111)),
            onPressed: () {},
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1),
        ),
      ),*/
      body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.price.market}, ${widget.price.district}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                                height: 1.25,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.visible,
                            ),
                                                        const SizedBox(height: 6),
                            Text(
                              'Last updated: ${DateFormat.yMMMd().add_jm().format(widget.price.createdAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEFF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.price.variety,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A5568),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPriceSummaryCard(context),
                  const SizedBox(height: 20),
                  _buildTrendSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }

  Widget _buildHeaderImage() {
    const String? imageUrl =
        "https://farm.ws/wp-content/uploads/2024/11/What-is-Crop-Farming_-Everything-You-Need-to-Know-930x620.webp";

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: const Color(0xFFE2E8F0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 44, color: Colors.grey.shade500),
            const SizedBox(height: 4),
            Text(
              'No preview available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context) {
    return FutureBuilder<List<PriceHistory>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];
        
        double? percentageChange;
        if (history.length >= 2) {
          final oldPrice = history.first.modalPrice;
          final newPrice = history.last.modalPrice;
          if (oldPrice != 0) {
            percentageChange = ((newPrice - oldPrice) / oldPrice) * 100;
          }
        } else if (history.length == 1) {
          percentageChange = 0.0;
        }

        final priceChangeColor = (percentageChange == null || percentageChange == 0)
            ? const Color(0xFF616161) // Neutral
            : (percentageChange > 0 ? const Color(0xFF007A33) : const Color(0xFFD32F2F));
            
        final priceChangeIcon = (percentageChange == null || percentageChange == 0)
            ? null
            : (percentageChange > 0 ? Icons.arrow_upward : Icons.arrow_downward);

        final displayPercentage = percentageChange != null
            ? '${percentageChange >= 0 ? "+" : ""}${percentageChange.toStringAsFixed(2)}%'
            : 'N/A';

        final currencyFormatter = NumberFormat.currency(
            locale: 'en_IN', symbol: '₹', decimalDigits: 0);

        final formattedModal =
            '${currencyFormatter.format(widget.price.modalPrice)} / Quintal';
        final formattedHigh =
            '${currencyFormatter.format(widget.price.highPrice)} / Quintal';
        final formattedLow =
            '${currencyFormatter.format(widget.price.lowPrice)} / Quintal';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Price Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priceChangeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          if (priceChangeIcon != null) ...[
                            Icon(priceChangeIcon, color: priceChangeColor, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            displayPercentage,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: priceChangeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('High Price', formattedHigh,
                          priceColor: const Color(0xFF007A33)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildPriceRow(
                        'Modal Price',
                        formattedModal,
                        priceColor: const Color(0xFF111111),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: Color(0xFFE2E8F0), height: 1),
                      ),
                      _buildPriceRow('Low Price', formattedLow,
                          priceColor: const Color(0xFFD32F2F)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 Widget _buildPriceRow(
  String label,
  String value, {
  required Color priceColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: priceColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTrendSection() {
    return FutureBuilder<List<PriceHistory>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF007A33)),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 250,
            child: Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: Text(
                'No historical data available',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDCDFE4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history.length}-Day Trend',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 190,
                  child: BarChart(
                    _buildChartData(history),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BarChartData _buildChartData(List<PriceHistory> history) {
    final maxPrice = history
        .map((e) => e.modalPrice)
        .reduce((a, b) => a > b ? a : b);
        
    final interval = maxPrice > 0 ? (maxPrice / 3).ceilToDouble() : 1000.0;

    return BarChartData(
      maxY: maxPrice * 1.2,
      minY: 0,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.shade200,
          strokeWidth: 1,
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => const Color(0xFF111111),
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final date = history[group.x.toInt()].date;
            final dateStr = DateFormat('MMM d').format(date);
            final priceStr = NumberFormat.currency(
              locale: 'en_IN',
              symbol: '₹',
              decimalDigits: 0,
            ).format(rod.toY);

            return BarTooltipItem(
              '$priceStr\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: dateStr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) {
              if (value == 0) {
                return SideTitleWidget(
                  meta: meta, // 👈 FIXED HERE
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                );
              }
              return SideTitleWidget(
                meta: meta, // 👈 FIXED HERE
                child: Text(
                  '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= history.length || value.toInt() < 0) {
                return const SizedBox();
              }

              return SideTitleWidget(
                meta: meta, // 👈 FIXED HERE
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('MMM d').format(history[value.toInt()].date),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: history
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.modalPrice,
                  width: 24,
                  color: const Color(0xFF007A33),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}