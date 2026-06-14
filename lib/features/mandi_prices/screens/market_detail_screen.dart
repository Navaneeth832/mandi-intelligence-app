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
State<MarketDetailScreen> createState() =>
    _MarketDetailScreenState();
}

class _MarketDetailScreenState
    extends State<MarketDetailScreen> {

  late Future<List<PriceHistory>>
      _historyFuture;

  final MandiRepository _repository =
      MandiRepository(
    MandiApiService(),
  );

  @override
  void initState() {
    super.initState();

    _historyFuture =
        _repository.getPriceHistory(
      commodity:
          widget.price.commodity,
      market:
          widget.price.market,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean premium light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111111), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.price.commodity,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF111111)),
            onPressed: () {
              // Handle refresh logic
            },
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1),
        ),
      ),
      body: SingleChildScrollView(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.price.market}, ${widget.price.district}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: ${DateFormat.yMMMd().add_jm().format(widget.price.lastUpdated)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPriceSummaryCard(context),
                  const SizedBox(height: 20),
                  _buildTrendSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    // Safely check if a preview image exists. 
    // You can replace this check with your model's actual image property later!
    final String? imageUrl = "https://farm.ws/wp-content/uploads/2024/11/What-is-Crop-Farming_-Everything-You-Need-to-Know-930x620.webp"; 

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: const Color(0xFFE2E8F0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 44, color: Colors.grey.shade500),
            const SizedBox(height: 8),
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
      decoration: BoxDecoration( // 👈 FIXED: Removed the 'const' keyword here
        color: Colors.white,
        image: DecorationImage(
          image: NetworkImage(imageUrl!), // 👈 FIXED: Added '!' to assert it isn't null
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _buildPriceSummaryCard(BuildContext context) {
    final priceChangeColor = widget.price.priceChange >= 0 ? const Color(0xFF007A33) : const Color(0xFFD32F2F);
    final priceChangeIcon = widget.price.priceChange >= 0 ? Icons.trending_up : Icons.trending_down;
    final formattedModal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.price.modalPrice);
    final formattedHigh = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.price.highPrice);
    final formattedLow = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(widget.price.lowPrice);

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priceChangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(priceChangeIcon, color: priceChangeColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.price.priceChange >= 0 ? "+" : ""}${widget.price.priceChange.toStringAsFixed(2)}%',
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
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow('High Price', formattedHigh, priceColor: const Color(0xFF007A33)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  _buildPriceRow('Modal Price', formattedModal, priceColor: const Color(0xFF111111)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  _buildPriceRow('Low Price', formattedLow, priceColor: const Color(0xFFD32F2F)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {required Color priceColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value, 
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: priceColor,
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

      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const SizedBox(
          height: 220,
          child: Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      }

      if (snapshot.hasError) {
        return SizedBox(
          height: 220,
          child: Center(
            child: Text(
              snapshot.error.toString(),
            ),
          ),
        );
      }

      final history =
          snapshot.data ?? [];

      if (history.isEmpty) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'No historical data available',
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                const Color(0xFFDCDFE4),
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '${history.length}-Day Trend',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 220,
                child: BarChart(
                  _buildChartData(
                    history,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

BarChartData _buildChartData(
  List<PriceHistory> history,
) {
  final maxPrice = history
      .map(
        (e) => e.modalPrice,
      )
      .reduce(
        (a, b) => a > b ? a : b,
      );

  return BarChartData(
    maxY: maxPrice * 1.2,
    minY: 0,
    borderData:
        FlBorderData(show: false),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
    ),
    titlesData: FlTitlesData(
      rightTitles:
          const AxisTitles(
        sideTitles:
            SideTitles(
          showTitles: false,
        ),
      ),
      topTitles:
          const AxisTitles(
        sideTitles:
            SideTitles(
          showTitles: false,
        ),
      ),
      bottomTitles:
          AxisTitles(
        sideTitles:
            SideTitles(
          showTitles: true,
          getTitlesWidget:
              (value, meta) {

            if (value.toInt() >=
                history.length) {
              return const SizedBox();
            }

            return SideTitleWidget(
              meta: meta,
              child: Text(
                DateFormat(
                  'MMM d',
                ).format(
                  history[
                          value
                              .toInt()]
                      .date,
                ),
                style:
                    const TextStyle(
                  fontSize: 10,
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
          (entry) =>
              BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry
                    .value
                    .modalPrice,
                width: 18,
                color:
                    const Color(
                  0xFF007A33,
                ),
              ),
            ],
          ),
        )
        .toList(),
  );
}
}