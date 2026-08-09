import 'package:flutter/material.dart';
import '../../../data/models/alert_model.dart';
import '../../../l10n/app_localizations.dart';

class AlertFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const AlertFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  String _getFilterLabel(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case 'ALL':
        return l10n.allAlerts;
      case AlertTypes.betterMarket:
        return l10n.betterMarket;
      case AlertTypes.priceIncrease:
        return l10n.priceIncrease;
      case AlertTypes.priceDrop:
        return l10n.priceDrop;
      case AlertTypes.aiRecommendation:
        return l10n.aiRecommendation;
      default:
        return l10n.allAlerts;
    }
  }

  @override
  Widget build(BuildContext context) {
    const filters = [
      'ALL',
      AlertTypes.betterMarket,
      AlertTypes.priceIncrease,
      AlertTypes.priceDrop,
      AlertTypes.aiRecommendation,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(_getFilterLabel(context, filter)),
              selectedColor: const Color(0xFF8EFF8E),
              checkmarkColor: const Color(0xFF0A4A1C),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF27A32D) : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1.0,
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0A4A1C) : Colors.grey.shade800,
              ),
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
