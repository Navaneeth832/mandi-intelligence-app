import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/alert_model.dart';
import '../../../l10n/app_localizations.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  String _getAlertTypeName(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AlertTypes.betterMarket:
        return l10n.betterMarket;
      case AlertTypes.priceIncrease:
        return l10n.priceIncrease;
      case AlertTypes.priceDrop:
        return l10n.priceDrop;
      case AlertTypes.aiRecommendation:
        return l10n.aiRecommendation;
      default:
        return type;
    }
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case AlertTypes.priceIncrease:
        return const Color(0xFF16A34A); // Green
      case AlertTypes.priceDrop:
        return const Color(0xFFDC2626); // Red
      case AlertTypes.betterMarket:
        return const Color(0xFF0284C7); // Blue
      case AlertTypes.aiRecommendation:
        return const Color(0xFF7C3AED); // Purple
      default:
        return const Color(0xFF27A32D);
    }
  }

  Color _getBackgroundColor(String type) {
    switch (type) {
      case AlertTypes.priceIncrease:
        return const Color(0xFFF0FDF4);
      case AlertTypes.priceDrop:
        return const Color(0xFFFEF2F2);
      case AlertTypes.betterMarket:
        return const Color(0xFFF0F9FF);
      case AlertTypes.aiRecommendation:
        return const Color(0xFFF5F3FF);
      default:
        return Colors.white;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case AlertTypes.priceIncrease:
        return Icons.trending_up;
      case AlertTypes.priceDrop:
        return Icons.trending_down;
      case AlertTypes.betterMarket:
        return Icons.storefront;
      case AlertTypes.aiRecommendation:
        return Icons.auto_awesome;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('d MMM, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getBadgeColor(alert.type);
    final bgColor = _getBackgroundColor(alert.type);
    final price = alert.price;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(color: primaryColor.withOpacity(0.25), width: 1.0),
      ),
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Type Badge + Severity + Time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(alert.type),
                      size: 18.0,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      _getAlertTypeName(context, alert.type),
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  if (alert.severity.toUpperCase() == 'HIGH')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        'HIGH',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _formatTime(alert.createdAt),
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 0, height: 12.0),

              // Title (Backend String)
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4.0),

              // Message (Backend String)
              Text(
                alert.message,
                style: TextStyle(
                  fontSize: 13.0,
                  height: 1.35,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10.0),

              // Commodity and Market Chips
              Row(
                children: [
                  Icon(Icons.eco_outlined, size: 14.0, color: Colors.grey.shade600),
                  const SizedBox(width: 4.0),
                  Text(
                    alert.commodity.name,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Icon(Icons.location_on_outlined, size: 14.0, color: Colors.grey.shade600),
                  const SizedBox(width: 4.0),
                  Text(
                    alert.market.name,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),

              // Price Box (Only displayed when price is available!)
              if (price != null) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Price',
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '₹${price.current.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      if (price.previous != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Previous Price',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '₹${price.previous!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      if (price.changePercent != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: price.changePercent! >= 0
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                price.changePercent! >= 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12.0,
                                color: price.changePercent! >= 0
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                              const SizedBox(width: 2.0),
                              Text(
                                '${price.changePercent! >= 0 ? '+' : ''}${price.changePercent!.abs().toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  color: price.changePercent! >= 0
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
