import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/commodity_model.dart';
import '../../../data/models/forecast_model.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/commodity_image_widget.dart';
import '../providers/forecast_provider.dart';
import '../widgets/forecast_card.dart';
import 'forecast_detail_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';
import '../../auth/providers/profile_notifier.dart';
import '../../mandi_prices/providers/mandi_prices_provider.dart';
import '../../mandi_prices/widgets/filter_dropdown.dart';

class CommodityAdvisoryScreen extends ConsumerStatefulWidget {
  final Commodity commodity;

  const CommodityAdvisoryScreen({
    super.key,
    required this.commodity,
  });

  @override
  ConsumerState<CommodityAdvisoryScreen> createState() => _CommodityAdvisoryScreenState();
}

class _CommodityAdvisoryScreenState extends ConsumerState<CommodityAdvisoryScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<CommodityForecast> _predictions = [];
  int _currentPage = 1;
  bool _hasNext = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int? _loadedDistrictId;
  String? _loadedDistrictName;

  String? _tempMarket;
  String? _tempGrade;
  String? _tempVariety;

  String? _appliedMarket;
  String? _appliedGrade;
  String? _appliedVariety;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchInitialData(int? districtId, String? districtName) async {
    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _currentPage = 1;
      _predictions.clear();
      _hasNext = true;
      _loadedDistrictId = districtId;
      _loadedDistrictName = districtName;
    });

    try {
      final repository = ref.read(forecastRepositoryProvider);
      final locale = ref.read(localeProvider);

      final response = await repository.getForecastsForPreferredCrops(
        language: locale.languageCode,
        page: 1,
        pageSize: 30,
        commodityId: widget.commodity.id,
        districtId: districtId,
      );

      if (mounted) {
        setState(() {
          _predictions.addAll(response.predictions);
          _hasNext = response.hasNext;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingInitial = false;
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore || !_hasNext || _isLoadingInitial) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repository = ref.read(forecastRepositoryProvider);
      final locale = ref.read(localeProvider);
      final nextPage = _currentPage + 1;

      final response = await repository.getForecastsForPreferredCrops(
        language: locale.languageCode,
        page: nextPage,
        pageSize: 30,
        commodityId: widget.commodity.id,
        districtId: _loadedDistrictId,
      );

      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _predictions.addAll(response.predictions);
          _hasNext = response.hasNext;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }


  void _applyFilters() {
    setState(() {
      _appliedMarket = _tempMarket;
      _appliedGrade = _tempGrade;
      _appliedVariety = _tempVariety;
    });
  }

  void _clearFilters() {
    setState(() {
      _tempMarket = null;
      _tempGrade = null;
      _tempVariety = null;
      _appliedMarket = null;
      _appliedGrade = null;
      _appliedVariety = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final commodityDisplayName = widget.commodity.getDisplayName(locale.languageCode);

    // Watch user profile to get preferred district
    final profileAsync = ref.watch(profileNotifierProvider);
    final userProfile = profileAsync.value;
    final districtId = userProfile?.districtId;
    final districtName = userProfile?.districtName;

    // Trigger initial fetch when profile is loaded or district changed
    if (!profileAsync.isLoading) {
      if (_isLoadingInitial && _errorMessage == null && _predictions.isEmpty) {
        _fetchInitialData(districtId, districtName);
      } else if (_loadedDistrictId != districtId || _loadedDistrictName != districtName) {
        _fetchInitialData(districtId, districtName);
      }
    }

    final marketsAsync = ref.watch(marketsProvider(districtId));

    final bool hasTempFilters = _tempMarket != null || _tempGrade != null || _tempVariety != null;
    final bool hasAppliedFilters = _appliedMarket != null || _appliedGrade != null || _appliedVariety != null;

    // Extract available grades and varieties
    final gradesSet = <String>{};
    final varietiesSet = <String>{};
    for (final p in _predictions) {
      if (p.gradeName.trim().isNotEmpty) {
        gradesSet.add(p.gradeName.trim());
      }
      if (p.varietyName.trim().isNotEmpty) {
        varietiesSet.add(p.varietyName.trim());
      }
    }

    final gradeOptions = gradesSet.toList()..sort();
    final varietyOptions = varietiesSet.toList()..sort();
    final marketOptions = marketsAsync.value ?? [];

    // Apply active dropdown filters
    final filteredPredictions = _predictions.where((p) {
      if (_appliedMarket != null && _appliedMarket!.isNotEmpty) {
        if (p.marketName.toLowerCase() != _appliedMarket!.toLowerCase()) {
          return false;
        }
      }
      if (_appliedGrade != null && _appliedGrade!.isNotEmpty) {
        if (p.gradeName.toLowerCase() != _appliedGrade!.toLowerCase()) {
          return false;
        }
      }
      if (_appliedVariety != null && _appliedVariety!.isNotEmpty) {
        if (p.varietyName.toLowerCase() != _appliedVariety!.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();

    // Prioritize "Sell Today" / "SELL" recommendations at the top
    filteredPredictions.sort((a, b) {
      final aIsSell = a.recommendation.toUpperCase().contains('SELL');
      final bIsSell = b.recommendation.toUpperCase().contains('SELL');
      if (aIsSell && !bIsSell) return -1;
      if (!aIsSell && bIsSell) return 1;
      return 0;
    });

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
          controller: _scrollController,
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
                        color: const Color(0xFFF97316).withValues(alpha: 0.14), // Soft orange shadow
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
                        commodityId: widget.commodity.id,
                        imageUrl: widget.commodity.commodityImageUrl,
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

              const SizedBox(height: 12),

              // Filter Dropdowns Section
              if (_isLoadingInitial || profileAsync.isLoading)
                _buildShimmerLoading()
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 44, color: Color(0xFFEF4444)),
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
                          _errorMessage!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _fetchInitialData(districtId, districtName),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retryLabel),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Dropdowns Horizontal Scroll Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        // 1. Market Dropdown (Markets in user's preferred district)
                        SizedBox(
                          width: 160,
                          child: FilterDropdownButton<String>(
                            hintText: l10n.market,
                            items: marketOptions,
                            value: _tempMarket,
                            onChanged: (value) {
                              setState(() {
                                _tempMarket = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 2. Grade Dropdown (Grades of this commodity)
                        SizedBox(
                          width: 160,
                          child: FilterDropdownButton<String>(
                            hintText: l10n.grade,
                            items: gradeOptions,
                            value: _tempGrade,
                            onChanged: (value) {
                              setState(() {
                                _tempGrade = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 3. Variety Dropdown (Varieties of this commodity)
                        SizedBox(
                          width: 160,
                          child: FilterDropdownButton<String>(
                            hintText: l10n.variety,
                            items: varietyOptions,
                            value: _tempVariety,
                            onChanged: (value) {
                              setState(() {
                                _tempVariety = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons (Apply & Clear Filters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: hasTempFilters ? _applyFilters : null,
                            child: Text(
                              l10n.applyFilters,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hasTempFilters || hasAppliedFilters) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF97316),
                              side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _clearFilters,
                            child: Text(
                              l10n.clearAll,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Advisory Cards Section
                if (filteredPredictions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 52,
                            color: Color(0xFFFB923C), // Secondary Orange
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _predictions.isEmpty
                                ? l10n.noForecastsInDistrict
                                : l10n.noOptionsFound,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1F2937), // Primary Text
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_predictions.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.noForecastsInDistrictSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280), // Secondary Text
                              ),
                            ),
                          ],
                          if (hasAppliedFilters) ...[
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.refresh, color: Color(0xFFF97316)),
                              label: Text(
                                l10n.clearAll,
                                style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredPredictions.length,
                    itemBuilder: (context, index) {
                      final forecast = filteredPredictions[index];
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
                  ),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ),
                ],
              ],
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
