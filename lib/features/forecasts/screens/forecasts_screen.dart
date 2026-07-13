import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/forecast_provider.dart';
import '../widgets/forecast_card.dart';
import 'forecast_detail_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastsScreen extends ConsumerWidget {
  const ForecastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastsAsync = ref.watch(forecastsNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.forecasts,
              style: const TextStyle(
                color: Color.fromARGB(255, 26, 152, 9),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Text(
              'Your preferred crops',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MOCK DATA BANNER (Easy to remove later)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFFF3E0), // Amber-orange background
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFEF6C00), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'MOCK DATA - Forecasts are simulated.',
                      style: TextStyle(
                        color: Color(0xFFEF6C00),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Forecast List or other states
            Expanded(
              child: forecastsAsync.when(
                data: (forecasts) {
                  if (forecasts.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(forecastsNotifierProvider.notifier).refresh(),
                    color: const Color.fromARGB(255, 26, 152, 9),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: forecasts.length,
                      itemBuilder: (context, index) {
                        return ForecastCard(
                          forecast: forecasts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForecastDetailScreen(
                                  forecast: forecasts[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(context, error.toString(), ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 152, 9),
                foregroundColor: Colors.white,
              ),
              onPressed: () => ref.read(forecastsNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              color: Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              "No preferred crops selected.",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Select your preferred crops from your profile to receive forecasts.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
