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
            // Statistics placeholder - TODO: Load on demand
            const Center(child: Text('Detailed analytics loading...')),
          ],
        ),
      ),
    );
  }
}
