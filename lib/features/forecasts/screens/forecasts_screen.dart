import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/commodity_image_widget.dart';
import '../../../data/models/commodity_model.dart';
import '../providers/forecast_provider.dart';
import 'commodity_advisory_screen.dart';
import 'explore_placeholder_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

class ForecastsScreen extends ConsumerWidget {
  const ForecastsScreen({super.key});

  String _getCardSubtitle(String languageCode) {
    switch (languageCode) {
      case 'ml':
        return 'വില വിവരങ്ങളും വിപണി അടിസ്ഥാനത്തിലുള്ള വില താരതമ്യവും.';
      case 'hi':
        return 'कीमत की जानकारी और बाज़ार के हिसाब से कीमतों की तुलना।';
      case 'en':
      default:
        return 'Price details and market wise price comparsion.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final preferredCommoditiesAsync = ref.watch(preferredCommoditiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7), // Cream background
      body: SafeArea(
        child: preferredCommoditiesAsync.when(
          data: (commodities) {
            if (commodities.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              color: const Color(0xFFF97316), // Primary Orange
              onRefresh: () async {
                ref.invalidate(preferredCommoditiesProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom Premium Header (No AppBar)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF2E7), // Light Orange
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Color(0xFFF97316), // Primary Orange
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.advisory,
                                  style: const TextStyle(
                                    color: Color(0xFFF97316), // Primary Orange
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.yourPreferredCrops,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280), // Secondary Text
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFE0CC)),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF1F2937), // Primary Text
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Vertically scrollable list of preferred commodity cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commodities.length,
                      itemBuilder: (context, index) {
                        final commodity = commodities[index];
                        final displayName = commodity.getDisplayName(locale.languageCode);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommodityAdvisoryScreen(commodity: commodity),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(24),
                              splashColor: const Color(0xFFF97316).withOpacity(0.05),
                              highlightColor: const Color(0xFFF97316).withOpacity(0.02),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF97316).withOpacity(0.14),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Row(
                                        children: [
                                          CommodityImageWidget(
                                            commodityId: commodity.id,
                                            imageUrl: commodity.commodityImageUrl,
                                            height: 130,
                                            width: 130,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          displayName,
                                                          style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF1F2937), // Primary Text
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          _getCardSubtitle(locale.languageCode),
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xFF6B7280), // Secondary Text
                                                            height: 1.4,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFFFF2E7), // Light Orange
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        color: Color(0xFFF97316), // Primary Orange
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Top Right badge
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF97316),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(24),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.eco_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // "Explore Other Markets / Commodities" Button
                    ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 52,
                        ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF97316),
                          side: const BorderSide(
                            color: Color(0xFFF97316),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExplorePlaceholderScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_outlined,
                                    color: Color(0xFFF97316),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.exploreOtherMarketsCommodities,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF97316),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFFF97316),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error.toString(), ref),
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
              height: 130,
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

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF97316),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => ref.invalidate(preferredCommoditiesProvider),
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
              color: Color(0xFFFB923C),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPreferredCropsSelected,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPreferredCropsSelectedForecasts,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
