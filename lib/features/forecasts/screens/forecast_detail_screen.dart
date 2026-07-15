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
  // These variables simulate future API integration states
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
          widget.forecast.commodityName,
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 26, 152, 9),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingLabel,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 26, 152, 9),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: Text(l10n.retryLabel),
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
          // 1. Redesigned Premium Header Hierarchy
          _buildHeaderHierarchy(context),
          const SizedBox(height: 24),

          // 2. Recommendation & Trend Group Card
          _buildRecommendationTrendCard(context),
          const SizedBox(height: 16),

          // 3. Price metrics Overview Card
          _buildPriceOverviewCard(context),
          const SizedBox(height: 24),

          // 4. 7-Day Forecast Chart Section (Primary visual element)
          _buildChartSection(context),
          const SizedBox(height: 24),

          // 5. Daily Forecast Table/List Section
          _buildDailyForecastSection(context),
        ],
      ),
    );
  }

  Widget _buildHeaderHierarchy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String varietyGrade = widget.forecast.gradeName.isNotEmpty
        ? '${widget.forecast.varietyName} • ${widget.forecast.gradeName}'
        : widget.forecast.varietyName;

    String displayPredDate = widget.forecast.predictionDate;
    try {
      final parsedDate = DateTime.parse(widget.forecast.predictionDate);
      displayPredDate = DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Commodity Name
        Text(
          widget.forecast.commodityName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111),
            height: 1.2,
          ),
        ),
        if (varietyGrade.isNotEmpty) ...[
          const SizedBox(height: 4),
          // Variety • Grade
          Text(
            varietyGrade,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Location (Market, District, State)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.forecast.marketName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    '${widget.forecast.districtName}, ${widget.forecast.stateName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Prediction Date & Time
        Row(
          children: [
            Icon(Icons.history_toggle_off, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              '${l10n.latestPredictionLabel}: $displayPredDate, ${widget.forecast.predictionTime}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationTrendCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Recommendation translation and styling
    final recommendation = widget.forecast.recommendation.toUpperCase();
    Color recBgColor;
    Color recTextColor;
    IconData recIcon;
    String recommendationText;

    if (recommendation == 'SELL TODAY') {
      recBgColor = const Color(0xFFE8F5E9);
      recTextColor = const Color(0xFF2E7D32);
      recIcon = Icons.check_circle_outline;
      recommendationText = l10n.sellTodayLabel;
    } else if (recommendation == 'HOLD') {
      recBgColor = const Color(0xFFFFF3E0);
      recTextColor = const Color(0xFFE65100);
      recIcon = Icons.pause_circle_outline;
      recommendationText = l10n.holdLabel;
    } else {
      // WAIT
      recBgColor = const Color(0xFFEBF3FC);
      recTextColor = const Color(0xFF1976D2);
      recIcon = Icons.watch_later_outlined;
      recommendationText = l10n.waitLabel;
    }

    // Trend translation and styling
    final trend = widget.forecast.trend.toUpperCase();
    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (trend == 'RISING') {
      trendColor = const Color(0xFF2E7D32);
      trendIcon = Icons.trending_up;
      trendText = l10n.risingLabel;
    } else if (trend == 'FALLING') {
      trendColor = const Color(0xFFC62828);
      trendIcon = Icons.trending_down;
      trendText = l10n.fallingLabel;
    } else {
      trendColor = const Color(0xFF757575);
      trendIcon = Icons.trending_flat;
      trendText = l10n.stableLabel;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recommendationLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: recBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(recIcon, size: 16, color: recTextColor),
                        const SizedBox(width: 4),
                        Text(
                          recommendationText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: recTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1.5, height: 44, color: const Color(0xFFE2E8F0)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trendLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(trendIcon, size: 20, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
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
    );
  }

  Widget _buildPriceOverviewCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Trend color for expected peak styling
    final trend = widget.forecast.trend.toUpperCase();
    final Color trendColor = trend == 'RISING'
        ? const Color(0xFF2E7D32)
        : (trend == 'FALLING' ? const Color(0xFFC62828) : const Color(0xFF757575));

    String displayBestSellDate = widget.forecast.bestSellDate;
    try {
      final parsedDate = DateTime.parse(widget.forecast.bestSellDate);
      displayBestSellDate = DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.priceSummary,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentPriceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(widget.forecast.currentPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.5, height: 40, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expectedPeakPriceLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(widget.forecast.expectedPeakPrice),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${l10n.bestSellingDayLabel}:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  displayBestSellDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
            l10n.expectedPriceTrajectory,
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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.dailyForecastLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.detailedPriceForecasts,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
