import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/forecast_model.dart';

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
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Color and text styles for recommendations
    final recommendation = forecast.recommendation.toUpperCase();
    Color recBgColor;
    Color recTextColor;
    IconData recIcon;

    if (recommendation == 'SELL TODAY') {
      recBgColor = const Color(0xFFE8F5E9); // Light green
      recTextColor = const Color(0xFF2E7D32); // Dark green
      recIcon = Icons.check_circle_outline;
    } else if (recommendation == 'HOLD') {
      recBgColor = const Color(0xFFFFF3E0); // Light orange
      recTextColor = const Color(0xFFE65100); // Dark orange
      recIcon = Icons.pause_circle_outline;
    } else {
      // WAIT
      recBgColor = const Color(0xFFEBF3FC); // Light blue/grey
      recTextColor = const Color(0xFF1976D2); // Dark blue
      recIcon = Icons.watch_later_outlined;
    }

    // Trend styling
    final trend = forecast.trend.toUpperCase();
    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (trend == 'RISING') {
      trendColor = const Color(0xFF2E7D32); // Green
      trendIcon = Icons.trending_up;
      trendText = 'Rising';
    } else if (trend == 'FALLING') {
      trendColor = const Color(0xFFC62828); // Red
      trendIcon = Icons.trending_down;
      trendText = 'Falling';
    } else {
      trendColor = const Color(0xFF757575); // Grey
      trendIcon = Icons.trending_flat;
      trendText = 'Stable';
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
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Recommendation Badge & Trend Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        recommendation,
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
                    const SizedBox(width: 4),
                    Text(
                      trendText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Commodity Name
            Text(
              forecast.commodity,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 16),

            // Price Details Block
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Current Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Current Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(forecast.currentPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                  // Expected Peak Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Expected Peak',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(forecast.expectedPeakPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Best Selling Day Row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Best Day to Sell:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Outlined disabled View Forecast button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: null, // Disabled as requested
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Forecast',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
