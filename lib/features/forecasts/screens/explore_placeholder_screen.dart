import 'package:flutter/material.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ExplorePlaceholderScreen extends StatelessWidget {
  const ExplorePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.explorePlaceholderTitle,
          style: const TextStyle(
            color: Color(0xFF1F2937), // Primary Text
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937), // Primary Text
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E7), // Light Orange
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_outlined,
                    size: 64,
                    color: Color(0xFFF97316), // Primary Orange
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.explorePlaceholderTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937), // Primary Text
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.explorePlaceholderMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280), // Secondary Text
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
