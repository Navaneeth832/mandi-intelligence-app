import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/forecast_model.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastCard extends StatelessWidget {
  final CommodityForecast forecast;
  final VoidCallback? onTap;

  const ForecastCard({
    super.key,
    required this.forecast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Color and localized text styles for recommendations
    final recommendation = forecast.recommendation.toUpperCase();
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
      // WAIT
      recBgColor = const Color(0xFFFFF2E7); // Light Orange
      recTextColor = const Color(0xFFF97316); // Primary Orange
      recIcon = Icons.watch_later_rounded;
      recommendationText = l10n.waitLabel;
    }

    // Trend styling and localized text
    final trend = forecast.trend.toUpperCase();
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

    // Format best sell date to readable format if it's yyyy-MM-dd
    String displayDate = forecast.bestSellDate;
    try {
      final parsedDate = DateTime.parse(forecast.bestSellDate);
      displayDate = DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0), // 24px radius
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.14), // Soft orange shadow
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFE0CC), // Border Color
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.0),
          splashColor: const Color(0xFFF97316).withOpacity(0.05),
          highlightColor: const Color(0xFFF97316).withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Lots of padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Recommendation Badge & Trend Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: recBgColor,
                        borderRadius: BorderRadius.circular(12),
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
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, size: 20, color: trendColor),
                        const SizedBox(width: 6),
                        Text(
                          trendText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Commodity Name
                Text(
                  forecast.commodityName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937), // Primary Text
                  ),
                ),
                const SizedBox(height: 8),

                // Variety & Grade Labels Row
                if (forecast.varietyName.isNotEmpty || forecast.gradeName.isNotEmpty) ...[
                  Row(
                    children: [
                      if (forecast.varietyName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2E7), // Light Orange
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE0CC)),
                          ),
                          child: Text(
                            forecast.varietyName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF97316), // Primary Orange
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (forecast.varietyName.isNotEmpty && forecast.gradeName.isNotEmpty)
                        const SizedBox(width: 8),
                      if (forecast.gradeName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2E7), // Light Orange
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE0CC)),
                          ),
                          child: Text(
                            forecast.gradeName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF97316), // Primary Orange
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Location Row: Market • District, State
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFF97316)), // Orange pin
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${forecast.marketName} • ${forecast.districtName}, ${forecast.stateName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280), // Secondary Text
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Details Block
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF7), // Cream background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE0CC), width: 1),
                  ),
                  child: Row(
                    children: [
                      // Current Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              currencyFormatter.format(forecast.currentPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937), // Primary Text
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: const Color(0xFFFFE0CC)), // Orange border divider
                      // Expected Peak Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              currencyFormatter.format(forecast.expectedPeakPrice),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: trendColor, // Matches trend color (orange/red/amber)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Best Selling Day Row
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFF97316)),
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
                      displayDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937), // Primary Text
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Outlined disabled View Forecast button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF97316),
                      side: BorderSide(
                        color: onTap != null
                            ? const Color(0xFFF97316)
                            : const Color(0xFFFFE0CC),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // Rounded button
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.viewForecastLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: onTap != null
                                ? const Color(0xFFF97316)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: onTap != null
                              ? const Color(0xFFF97316)
                              : const Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
