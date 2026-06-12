import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/mandi_price.dart';

class MarketDetailScreen extends StatelessWidget {
  final MandiPrice price;

  const MarketDetailScreen({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(price.commodity),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Handle refresh logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${price.market}, ${price.district}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateFormat.yMMMd().add_jm().format(price.lastUpdated)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildPriceSummaryCard(context),
                  const SizedBox(height: 24),
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
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://via.placeholder.com/600x300.png/2E7D32/FFFFFF?text=Tomato'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final priceChangeColor = price.priceChange >= 0 ? Colors.green : Colors.red;
    final priceChangeIcon = price.priceChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final formattedModal = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(price.modalPrice);
    final formattedHigh = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(price.highPrice);
    final formattedLow = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(price.lowPrice);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price Summary', style: theme.textTheme.titleMedium),
                Row(
                  children: [
                    Icon(priceChangeIcon, color: priceChangeColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${price.priceChange.toStringAsFixed(2)}%',
                      style: theme.textTheme.titleMedium?.copyWith(color: priceChangeColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Modal Price', formattedModal, context),
            const Divider(height: 24),
            _buildPriceRow('High Price', formattedHigh, context),
            const Divider(height: 24),
            _buildPriceRow('Low Price', formattedLow, context),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _build7DayTrendSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('7-Day Trend', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: LineChart(_buildChartData(context)),
        ),
      ],
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final theme = Theme.of(context);
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 3.5),
            FlSpot(2, 3.2),
            FlSpot(3, 4),
            FlSpot(4, 3.8),
            FlSpot(5, 4.2),
            FlSpot(6, 4.5),
          ],
          isCurved: true,
          color: theme.primaryColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: theme.primaryColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
