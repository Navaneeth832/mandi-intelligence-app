import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../data/models/commodity_model.dart';
import '../providers/forecast_provider.dart';
import '../widgets/forecast_card.dart';
import 'forecast_detail_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ExploreAdvisoryResultsScreen extends ConsumerStatefulWidget {
  final List<Commodity> selectedCommodities;
  final List<int> selectedMarketIds;

  const ExploreAdvisoryResultsScreen({
    super.key,
    required this.selectedCommodities,
    required this.selectedMarketIds,
  });

  @override
  ConsumerState<ExploreAdvisoryResultsScreen> createState() => _ExploreAdvisoryResultsScreenState();
}

class _ExploreAdvisoryResultsScreenState extends ConsumerState<ExploreAdvisoryResultsScreen> {
  late Commodity _activeCommodity;

  @override
  void initState() {
    super.initState();
    _activeCommodity = widget.selectedCommodities.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    final predictionsAsync = ref.watch(
      explorePredictionsProvider((
        commodityId: _activeCommodity.id,
        marketIds: widget.selectedMarketIds.isNotEmpty ? widget.selectedMarketIds : null,
      )),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.exploreAdvisoryResults,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Commodity Chips Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFE0CC), width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: widget.selectedCommodities.map((commodity) {
                    final isSelected = commodity.id == _activeCommodity.id;
                    final displayName = commodity.getDisplayName(locale.languageCode);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(displayName),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF97316),
                        backgroundColor: const Color(0xFFFFF2E7),
                        elevation: isSelected ? 2 : 0,
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFFE0CC),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activeCommodity = commodity;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Active Commodity Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: Color(0xFFF97316), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_activeCommodity.getDisplayName(locale.languageCode)} ${l10n.advisory}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Predictions Cards List
            Expanded(
              child: predictionsAsync.when(
                data: (response) {
                  final predictions = response.predictions;
                  if (predictions.isEmpty) {
                    return _buildEmptyState(context, l10n);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFF97316),
                    onRefresh: () async {
                      ref.invalidate(
                        explorePredictionsProvider((
                          commodityId: _activeCommodity.id,
                          marketIds: widget.selectedMarketIds.isNotEmpty ? widget.selectedMarketIds : null,
                        )),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final forecast = predictions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ForecastCard(
                            forecast: forecast,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForecastDetailScreen(forecast: forecast),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingState(),
                error: (err, stack) => _buildErrorState(context, err.toString(), ref),
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
        baseColor: Colors.orange[100]!,
        highlightColor: Colors.orange[50]!,
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFFFB923C),
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPricesFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noPricesFoundSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFF97316), size: 56),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Color(0xFF6B7280)), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                ref.invalidate(
                  explorePredictionsProvider((
                    commodityId: _activeCommodity.id,
                    marketIds: widget.selectedMarketIds.isNotEmpty ? widget.selectedMarketIds : null,
                  )),
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
