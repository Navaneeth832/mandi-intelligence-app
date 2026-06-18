import 'package:flutter/material.dart';
import '../../../data/models/market_directory_model.dart';

class MarketDirectoryDetailScreen extends StatelessWidget {
  final MarketDirectory market;

  const MarketDirectoryDetailScreen({super.key, required this.market});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(market.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF14522B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(market.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF14522B))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${market.district}, ${market.state}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Statistics Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Available Crops Today', market.commodityCount.toString())),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Total Records', market.totalRecords.toString())),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Available Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: market.commodities.map((c) => Chip(
                label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: const Color(0xFFE2E5E8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF14522B))),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
