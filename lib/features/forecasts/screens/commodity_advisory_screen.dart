import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/commodity_model.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/commodity_image_widget.dart';
import '../providers/forecast_provider.dart';
import '../widgets/forecast_card.dart';
import 'forecast_detail_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class CommodityAdvisoryScreen extends ConsumerWidget {
  final Commodity commodity;

  const CommodityAdvisoryScreen({
    super.key,
    required this.commodity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final predictionsAsync = ref.watch(commodityPredictionsProvider(commodity.id));
    final commodityDisplayName = commodity.getDisplayName(locale.languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937), // Primary Text
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          commodityDisplayName,
          style: const TextStyle(
            color: Color(0xFF1F2937), // Primary Text
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Commodity Header Image & Title Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24), // 24px radius
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.14), // Soft orange shadow
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFFE0CC), // Border
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommodityImageWidget(
                        commodityId: commodity.id,
                        imageUrl: commodity.commodityImageUrl,
                        height: 180,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0), // Lots of padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commodityDisplayName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937), // Primary Text
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.advisory,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280), // Secondary Text
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF2E7), // Light Orange
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                color: Color(0xFFF97316), // Primary Orange
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Advisory Cards Section
              predictionsAsync.when(
                data: (response) {
                  final predictions = response.predictions;
                  if (predictions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.storefront_outlined,
                              size: 48,
                              color: Color(0xFFFB923C), // Secondary Orange
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noForecastsAvailable,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280), // Secondary Text
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      final forecast = predictions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
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
                  );
                },
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 44, color: Color(0xFFEF4444)), // Red error
                        const SizedBox(height: 12),
                        Text(
                          l10n.somethingWentWrong,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.orange[100]!,
            highlightColor: Colors.orange[50]!,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        );
      },
    );
  }
}
