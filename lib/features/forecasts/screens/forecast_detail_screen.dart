import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/forecast_model.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastDetailScreen extends StatefulWidget {
  final CommodityForecast forecast;

  const ForecastDetailScreen({
    super.key,
    required this.forecast,
  });

  @override
  State<ForecastDetailScreen> createState() => _ForecastDetailScreenState();
}

class _ForecastDetailScreenState extends State<ForecastDetailScreen> {
  // These boolean flags simulate future api integration states
  final bool _isLoading = false;
  final String? _errorMessage = null;

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.forecast.commodity,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1),
        ),
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Structural layout that easily allows adding loading/error states in the future
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 26, 152, 9),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Summary Card
          _buildHeroSummaryCard(context),
          const SizedBox(height: 24),

          // 2. 7-Day Forecast Chart Section
          _buildChartSection(context),
          const SizedBox(height: 24),

          // 3. Daily Forecast Table/List Section
          _buildDailyForecastSection(context),
        ],
      ),
    );
  }

  Widget _buildHeroSummaryCard(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Color and text styles for recommendations
    final recommendation = widget.forecast.recommendation.toUpperCase();
    Color recBgColor;
    Color recTextColor;
    IconData recIcon;

    if (recommendation == 'SELL TODAY') {
      recBgColor = const Color(0xFFE8F5E9);
      recTextColor = const Color(0xFF2E7D32);
      recIcon = Icons.check_circle_outline;
    } else if (recommendation == 'HOLD') {
      recBgColor = const Color(0xFFFFF3E0);
      recTextColor = const Color(0xFFE65100);
      recIcon = Icons.pause_circle_outline;
    } else {
      // WAIT
      recBgColor = const Color(0xFFEBF3FC);
      recTextColor = const Color(0xFF1976D2);
      recIcon = Icons.watch_later_outlined;
    }

    // Trend styling
    final trend = widget.forecast.trend.toUpperCase();
    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (trend == 'RISING') {
      trendColor = const Color(0xFF2E7D32);
      trendIcon = Icons.trending_up;
      trendText = 'Rising';
    } else if (trend == 'FALLING') {
      trendColor = const Color(0xFFC62828);
      trendIcon = Icons.trending_down;
      trendText = 'Falling';
    } else {
      trendColor = const Color(0xFF757575);
      trendIcon = Icons.trending_flat;
      trendText = 'Stable';
    }

    String displayDate = widget.forecast.bestSellDate;
    try {
      final parsedDate = DateTime.parse(widget.forecast.bestSellDate);
      displayDate = DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (_) {}

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.forecast.commodity,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Market Forecast Summary',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: recBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(recIcon, size: 16, color: recTextColor),
                      const SizedBox(width: 4),
                      Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: recTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: Color(0xFFEEEEEE)),
            
            // Detail metrics grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Current Price',
                    currencyFormatter.format(widget.forecast.currentPrice),
                    Colors.black87,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    'Expected Peak',
                    currencyFormatter.format(widget.forecast.expectedPeakPrice),
                    trendColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Trend',
                    trendText,
                    trendColor,
                    icon: Icon(trendIcon, size: 18, color: trendColor),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    'Best Day to Sell',
                    displayDate,
                    const Color(0xFF2E7D32),
                    icon: const Icon(Icons.star, size: 18, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor, {Widget? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final theme = Theme.of(context);
    final forecast = widget.forecast.forecast;

    if (forecast.isEmpty) {
      return const SizedBox();
    }

    final prices = forecast.map((f) => f.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    // Setup nice Y bounds
    final minY = (minPrice * 0.96).floorToDouble();
    final maxY = (maxPrice * 1.04).ceilToDouble();
    final interval = ((maxY - minY) / 3).ceilToDouble();

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-Day Trend Chart',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Expected price trajectory for next 7 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                maxY: maxY,
                minY: minY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF111111),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index < 0 || index >= forecast.length) return null;
                        
                        final f = forecast[index];
                        String dateStr = f.date;
                        try {
                          final parsed = DateTime.parse(f.date);
                          dateStr = DateFormat('MMM d').format(parsed);
                        } catch (_) {}

                        return LineTooltipItem(
                          '${currencyFormatter.format(touchedSpot.y)}\n',
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
                      }).toList();
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
                      reservedSize: 56,
                      interval: interval > 0 ? interval : 100,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8.0,
                          child: Text(
                            currencyFormatter.format(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= forecast.length) {
                          return const SizedBox();
                        }
                        
                        final f = forecast[index];
                        String dateLabel = f.date;
                        try {
                          final parsed = DateTime.parse(f.date);
                          dateLabel = DateFormat('MMM d').format(parsed);
                        } catch (_) {}

                        return SideTitleWidget(
                          meta: meta,
                          space: 10.0,
                          child: Transform.rotate(
                            angle: -math.pi / 6,
                            child: Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: forecast
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.price))
                        .toList(),
                    isCurved: true,
                    color: const Color.fromARGB(255, 26, 152, 9),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: const Color.fromARGB(255, 26, 152, 9),
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 26, 152, 9).withOpacity(0.2),
                          const Color.fromARGB(255, 26, 152, 9).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastSection(BuildContext context) {
    final theme = Theme.of(context);
    final forecast = widget.forecast.forecast;
    final bestSellDate = widget.forecast.bestSellDate;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.5),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Predictions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Detailed price forecasts for each of the upcoming 7 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),

          // Daily rows
          Column(
            children: forecast.map((day) {
              final isBestDay = day.date == bestSellDate;
              
              String rowDateFormatted = day.date;
              try {
                final parsed = DateTime.parse(day.date);
                rowDateFormatted = DateFormat('EEEE, dd MMM').format(parsed);
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isBestDay ? const Color(0xFFE8F5E9) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBestDay ? const Color(0xFF2E7D32) : const Color(0xFFECEFF1),
                    width: isBestDay ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isBestDay) ...[
                          const Icon(Icons.star, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                        ] else ...[
                          const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          rowDateFormatted,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isBestDay ? FontWeight.bold : FontWeight.w600,
                            color: isBestDay ? const Color(0xFF1B5E20) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          currencyFormatter.format(day.price),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isBestDay ? const Color(0xFF1B5E20) : Colors.black87,
                          ),
                        ),
                        if (isBestDay) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BEST DAY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
