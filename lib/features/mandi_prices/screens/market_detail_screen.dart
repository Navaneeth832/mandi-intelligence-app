import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/mandi_price.dart';

class MarketDetailScreen extends StatelessWidget {
  final MandiPrice price;

  const MarketDetailScreen({super.key, required this.price});

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
          price.commodity,
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
                              '${price.market}, ${price.district}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last updated: ${DateFormat.yMMMd().add_jm().format(price.lastUpdated)}',
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
                          price.variety,
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
                  _build7DayTrendSection(context),
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
    final priceChangeColor = price.priceChange >= 0 ? const Color(0xFF007A33) : const Color(0xFFD32F2F);
    final priceChangeIcon = price.priceChange >= 0 ? Icons.trending_up : Icons.trending_down;
    final formattedModal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(price.modalPrice);
    final formattedHigh = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(price.highPrice);
    final formattedLow = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(price.lowPrice);

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
                        '${price.priceChange >= 0 ? "+" : ""}${price.priceChange.toStringAsFixed(2)}%',
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

  Widget _build7DayTrendSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Trend', 
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 4.0),
                child: BarChart(_buildChartData(context)), // 👈 CHANGED: Upgraded to BarChart
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(BuildContext context) {
    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xFFE2E8F0),
            strokeWidth: 1,
            dashArray: [4, 4],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 10, // Adjust grid spacing based on your price range
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  '₹${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      alignment: BarChartAlignment.spaceAround,
      maxY: 60, // Feel free to dynamically calculate or adjust based on data points
      minY: 0,
      barGroups: [
        _makeBarGroup(0, 35),
        _makeBarGroup(1, 42),
        _makeBarGroup(2, 38),
        _makeBarGroup(3, 48),
        _makeBarGroup(4, 40),
        _makeBarGroup(5, 45),
        _makeBarGroup(6, 52),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF007A33), // Exact matching forest green brand color
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}