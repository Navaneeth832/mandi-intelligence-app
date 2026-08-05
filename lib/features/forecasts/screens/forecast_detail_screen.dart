import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../data/models/forecast_model.dart';
import '../../../core/widgets/commodity_image_widget.dart';
import '../providers/forecast_provider.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastDetailScreen extends ConsumerStatefulWidget {
  final CommodityForecast forecast;

  const ForecastDetailScreen({
    super.key,
    required this.forecast,
  });

  @override
  ConsumerState<ForecastDetailScreen> createState() => _ForecastDetailScreenState();
}

class _ForecastDetailScreenState extends ConsumerState<ForecastDetailScreen> {
  final bool _isLoading = false;
  final String? _errorMessage = null;

  Future<void> _onTapMarket(BestMarket mkt) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFF97316)),
      ),
    );

    try {
      final repository = ref.read(forecastRepositoryProvider);
      final locale = ref.read(localeProvider);
      final response = await repository.getForecastsForPreferredCrops(
        language: locale.languageCode,
        commodityId: widget.forecast.commodityId,
        marketId: mkt.marketId,
        pageSize: 1,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (response.predictions.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForecastDetailScreen(forecast: response.predictions.first),
          ),
        );
      } else {
        // Fallback: construct CommodityForecast from BestMarket
        final fallbackForecast = CommodityForecast(
          commodityId: widget.forecast.commodityId,
          commodityName: widget.forecast.commodityName,
          commodityImageUrl: widget.forecast.commodityImageUrl,
          marketId: mkt.marketId,
          marketName: mkt.marketName,
          districtId: mkt.districtId,
          districtName: mkt.districtName,
          stateId: mkt.stateId,
          stateName: mkt.stateName,
          varietyId: mkt.varietyId,
          varietyName: mkt.varietyName,
          gradeId: mkt.gradeId,
          gradeName: mkt.gradeName,
          predictionDate: widget.forecast.predictionDate,
          predictionTime: widget.forecast.predictionTime,
          currentPrice: mkt.currentPrice,
          forecast: widget.forecast.forecast,
          trend: mkt.trend,
          bestSellDate: widget.forecast.bestSellDate,
          expectedPeakPrice: mkt.predictedPrice,
          recommendation: mkt.recommendation,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForecastDetailScreen(forecast: fallbackForecast),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937), // Primary Text
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.forecast.commodityName,
          style: const TextStyle(
            color: Color(0xFF1F2937), // Primary Text
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
              color: Color(0xFFF97316), // Primary Orange
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingLabel,
              style: const TextStyle(color: Color(0xFF6B7280)),
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
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
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
          // 1. Commodity Image Header
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24), // 24px radius
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.14), // Soft orange shadow
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFFE0CC),
                width: 1,
              ),
            ),
            child: CommodityImageWidget(
              commodityId: widget.forecast.commodityId,
              imageUrl: widget.forecast.commodityImageUrl,
              height: 180,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Redesigned Premium Header Hierarchy (Commodity Name, Variety, Grade, Selected Market)
          _buildHeaderHierarchy(context),
          const SizedBox(height: 24),

          // 3. Recommendation & Trend Group Card
          _buildRecommendationTrendCard(context),
          const SizedBox(height: 16),

          // 4. Price metrics Overview Card (Peak Price, Current Price, Best Sell Date)
          _buildPriceOverviewCard(context),
          const SizedBox(height: 20),

          // 5. 7-Day Forecast Graph Section
          _buildChartSection(context),
          const SizedBox(height: 24),

          // 6. Best Markets Section (Replaces date list)
          _buildBestMarketsSection(context),
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // Primary Text
            height: 1.2,
          ),
        ),
        if (varietyGrade.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Variety • Grade
          Text(
            varietyGrade,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280), // Secondary Text
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Selected Market (Market, District, State)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFFF97316)), // Orange icon
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.forecast.marketName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937), // Primary Text
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.forecast.districtName}, ${widget.forecast.stateName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280), // Secondary Text
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Prediction Date & Time
        Row(
          children: [
            const Icon(Icons.history_toggle_off_rounded, size: 15, color: Color(0xFFF97316)), // Orange history icon
            const SizedBox(width: 6),
            Text(
              '${l10n.latestPredictionLabel}: $displayPredDate, ${widget.forecast.predictionTime}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280), // Secondary Text
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

    final recommendation = widget.forecast.recommendation.toUpperCase();
    Color recBgColor;
    Color recTextColor;
    IconData recIcon;
    String recommendationText;

    if (recommendation == 'SELL TODAY') {
      recBgColor = const Color(0xFFF97316); // Solid Orange
      recTextColor = Colors.white; // White text
      recIcon = Icons.check_circle_rounded;
      recommendationText = l10n.sellTodayLabel;
    } else if (recommendation == 'HOLD') {
      recBgColor = const Color(0xFFF3F4F6); // Grey
      recTextColor = const Color(0xFF6B7280); // Grey text
      recIcon = Icons.pause_circle_rounded;
      recommendationText = l10n.holdLabel;
    } else {
      recBgColor = const Color(0xFFFFF2E7); // Light Orange
      recTextColor = const Color(0xFFF97316); // Orange text
      recIcon = Icons.watch_later_rounded;
      recommendationText = l10n.waitLabel;
    }

    final trend = widget.forecast.trend.toUpperCase();
    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (trend == 'RISING') {
      trendColor = const Color(0xFFF97316); // Orange
      trendIcon = Icons.trending_up_rounded;
      trendText = l10n.risingLabel;
    } else if (trend == 'FALLING') {
      trendColor = const Color(0xFFEF4444); // Red
      trendIcon = Icons.trending_down_rounded;
      trendText = l10n.fallingLabel;
    } else {
      trendColor = const Color(0xFFF59E0B); // Amber
      trendIcon = Icons.trending_flat_rounded;
      trendText = l10n.stableLabel;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 24 radius
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.0), // Orange-tinted border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.14),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Premium padding
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recommendationLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280), // Secondary Text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: recBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(recIcon, size: 16, color: recTextColor),
                        const SizedBox(width: 6),
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
            Container(width: 1.5, height: 48, color: const Color(0xFFFFE0CC)), // Orange divider
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trendLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280), // Secondary Text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(trendIcon, size: 20, color: trendColor),
                      const SizedBox(width: 6),
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

    final trend = widget.forecast.trend.toUpperCase();
    final Color trendColor = trend == 'RISING'
        ? const Color(0xFFF97316) // Orange
        : (trend == 'FALLING' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    String displayBestSellDate = widget.forecast.bestSellDate;
    try {
      final parsedDate = DateTime.parse(widget.forecast.bestSellDate);
      displayBestSellDate = DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 24 radius
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.14),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Premium padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.priceSummary,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // Primary Text
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280), // Secondary Text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormatter.format(widget.forecast.currentPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937), // Primary Text
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.5, height: 40, color: const Color(0xFFFFE0CC)), // Orange divider
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expectedPeakPriceLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280), // Secondary Text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormatter.format(widget.forecast.expectedPeakPrice),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: trendColor, // Trend Color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: Color(0xFFFFE0CC)), // Orange divider
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF97316), size: 22),
                const SizedBox(width: 8),
                Text(
                  '${l10n.bestSellingDayLabel}:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // Secondary Text
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayBestSellDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316), // Orange color
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
        borderRadius: BorderRadius.circular(24), // 24 radius
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.14),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sevenDayTrendChart,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.expectedPriceTrajectory,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
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
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFFFF2E7), // Very light orange grid
                    strokeWidth: 1,
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => Colors.white, // White card tooltip
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
                            color: Color(0xFFF97316), // Orange price title
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: dateStr,
                              style: const TextStyle(
                                color: Color(0xFF6B7280), // Secondary text date
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
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280), // Grey text
                              fontWeight: FontWeight.bold,
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
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF6B7280), // Grey text
                                fontWeight: FontWeight.bold,
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
                    color: const Color(0xFFF97316), // Orange line
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFFEA580C), // Deep Orange dots
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFF2E7), // Light Orange gradient
                          const Color(0xFFFFF2E7).withOpacity(0.0),
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

  Widget _buildBestMarketsSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bestMarketsAsync = ref.watch(bestMarketsProvider(widget.forecast.commodityId));

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 24 radius
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.14),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFF97316), size: 24), // Orange icon
              const SizedBox(width: 8),
              Text(
                l10n.bestMarkets,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.marketsSortedByHighestPredictedPrice,
            maxLines: 2,
            softWrap: true,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),

          bestMarketsAsync.when(
            data: (markets) {
              if (markets.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    l10n.noMarketsFound,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                );
              }

              return Column(
                children: markets.map((mkt) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTapMarket(mkt),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF7), // Cream background
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFE0CC), // Orange border
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mkt.marketName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${mkt.districtName}, ${mkt.stateName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  if (mkt.varietyName.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      mkt.gradeName.isNotEmpty
                                          ? '${mkt.varietyName} • ${mkt.gradeName}'
                                          : mkt.varietyName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(mkt.predictedPrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF97316), // Orange color
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Builder(
                                  builder: (context) {
                                    final mktRec = mkt.recommendation.toUpperCase();
                                    Color recBg;
                                    Color recText;
                                    if (mktRec.contains('SELL') || mktRec.contains('വിൽപ്പന')) {
                                      recBg = const Color(0xFFF97316);
                                      recText = Colors.white;
                                    } else if (mktRec.contains('HOLD') || mktRec.contains('കൈവശം')) {
                                      recBg = const Color(0xFFF3F4F6);
                                      recText = const Color(0xFF6B7280);
                                    } else {
                                      recBg = const Color(0xFFFFF2E7);
                                      recText = const Color(0xFFF97316);
                                    }
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: recBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        mkt.recommendation,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: recText,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => Shimmer.fromColors(
              baseColor: Colors.orange[100]!,
              highlightColor: Colors.orange[50]!,
              child: Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            error: (error, stack) => Text(
              error.toString(),
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
