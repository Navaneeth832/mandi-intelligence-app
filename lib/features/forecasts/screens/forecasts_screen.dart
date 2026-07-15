import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../providers/forecast_provider.dart';
import '../widgets/forecast_card.dart';
import 'forecast_detail_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastsScreen extends ConsumerWidget {
  const ForecastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastsAsync = ref.watch(forecastsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

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
              l10n.forecasts,
              style: const TextStyle(
                color: Color.fromARGB(255, 26, 152, 9),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              l10n.yourPreferredCrops,
              style: const TextStyle(
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
            // Forecast states switcher
            Expanded(
              child: forecastsAsync.when(
                data: (paginatedResponse) {
                  final forecasts = paginatedResponse.predictions;
                  if (forecasts.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Retrieve prediction date/time from the first forecast in the batch
                  final latestPrediction = forecasts.first;
                  final dateVal = latestPrediction.predictionDate;
                  final timeVal = latestPrediction.predictionTime;

                  String formattedDate = dateVal;
                  try {
                    final parsed = DateTime.parse(dateVal);
                    formattedDate = DateFormat('dd MMM, yyyy').format(parsed);
                  } catch (_) {}

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.history_toggle_off, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.latestPredictionLabel}: $formattedDate, $timeVal',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
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
                        ),
                      ),
                    ],
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.somethingWentWrong,
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
              label: Text(l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
              l10n.noPreferredCropsSelected,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPreferredCropsSelectedForecasts,
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
