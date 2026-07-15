import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/mandi_price.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class PriceCard extends StatelessWidget {
  final MandiPrice price;
  final VoidCallback? onTap;

  const PriceCard({
    super.key,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFDCDFE4), width: 1.5), // Distinct light card stroke
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildPriceSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price.getDisplayCommodity(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price.variety,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (price.grade.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            price.grade,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          price.market,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${price.district}, ${price.state}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8), // Embedded price section row background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildPriceColumn(context, AppLocalizations.of(context)!.high, price.highPrice, isHigh: true, isLow: false)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)), // Column borders
          Expanded(child: _buildPriceColumn(context, AppLocalizations.of(context)!.modal, price.modalPrice, isHigh: false, isLow: false)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildPriceColumn(context, AppLocalizations.of(context)!.low, price.lowPrice, isHigh: false, isLow: true)),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(BuildContext context, String label, double priceValue, {required bool isHigh, required bool isLow}) {
    final formattedPrice = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(priceValue);
    
    Color priceColor = const Color(0xFF111111);
    String arrow = '';
    
    if (isHigh) {
      priceColor = const Color(0xFF007A33); // Green theme match
      arrow = ' ↑';
    } else if (isLow) {
      priceColor = const Color(0xFFD32F2F); // Red theme match
      arrow = ' ↓';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: priceColor,
            ),
            children: [
              TextSpan(text: formattedPrice),
              if (arrow.isNotEmpty)
                TextSpan(
                  text: arrow,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
