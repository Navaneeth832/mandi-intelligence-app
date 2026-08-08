import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../data/models/commodity_model.dart';
import '../../../data/models/district_model.dart';
import '../../../data/models/market_model.dart';
import '../../../data/models/state_model.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';
import '../../mandi_prices/providers/mandi_prices_provider.dart';
import '../../mandi_prices/widgets/filter_dropdown.dart';
import 'explore_advisory_results_screen.dart';


class ExploreMoreCommoditiesScreen extends ConsumerStatefulWidget {
  const ExploreMoreCommoditiesScreen({super.key});

  @override
  ConsumerState<ExploreMoreCommoditiesScreen> createState() => _ExploreMoreCommoditiesScreenState();
}

class _ExploreMoreCommoditiesScreenState extends ConsumerState<ExploreMoreCommoditiesScreen> {
  int? _selectedStateId;
  int? _selectedDistrictId;
  final Set<int> _selectedMarketIds = {};
  final Set<int> _selectedCommodityIds = {};
  String _marketSearchQuery = '';
  String _commoditySearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    final statesAsync = ref.watch(statesProvider);
    final activeCommoditiesAsync = ref.watch(activeCommoditiesProvider);
    final districtsAsync = _selectedStateId != null ? ref.watch(districtsProvider(_selectedStateId)) : null;
    final marketsAsync = _selectedDistrictId != null ? ref.watch(marketsListProvider(_selectedDistrictId)) : null;

    final canShowAdvisory = _selectedStateId != null &&
        _selectedDistrictId != null &&
        _selectedCommodityIds.isNotEmpty;

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
          l10n.exploreMoreCommodities,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Select State
                    _buildSectionHeader(
                      icon: Icons.map_outlined,
                      title: l10n.selectState,
                    ),
                    const SizedBox(height: 8),
                    statesAsync.when(
                      data: (states) => _buildStateDropdown(states, locale.languageCode),
                      loading: () => _buildDropdownShimmer(),
                      error: (err, _) => Text(err.toString(), style: const TextStyle(color: Colors.red)),
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Select District
                    _buildSectionHeader(
                      icon: Icons.location_city_outlined,
                      title: l10n.selectDistrict,
                    ),
                    const SizedBox(height: 8),
                    if (_selectedStateId == null)
                      _buildDisabledField(l10n.selectStateFirst)
                    else
                      districtsAsync!.when(
                        data: (districts) => _buildDistrictDropdown(districts, locale.languageCode),
                        loading: () => _buildDropdownShimmer(),
                        error: (err, _) => Text(err.toString(), style: const TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 20),

                    // Section 3: Select Markets (Multi Select)
                    _buildSectionHeader(
                      icon: Icons.storefront_outlined,
                      title: l10n.selectMarkets,
                      subtitle: _selectedMarketIds.isNotEmpty
                          ? '${_selectedMarketIds.length} selected'
                          : 'Optional (All markets in district if unselected)',
                    ),
                    const SizedBox(height: 8),
                    if (_selectedDistrictId == null)
                      _buildDisabledField(l10n.selectDistrict)
                    else
                      marketsAsync!.when(
                        data: (markets) => _buildMarketsSelector(markets, locale.languageCode),
                        loading: () => _buildDropdownShimmer(),
                        error: (err, _) => Text(err.toString(), style: const TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 20),

                    // Section 4: Commodity Selection (Multi Select Active Commodities)
                    _buildSectionHeader(
                      icon: Icons.eco_outlined,
                      title: l10n.selectCommodities,
                      subtitle: '${_selectedCommodityIds.length} selected',
                    ),
                    const SizedBox(height: 8),
                    activeCommoditiesAsync.when(
                      data: (commodities) => _buildCommoditiesSelector(commodities, locale.languageCode),
                      loading: () => _buildDropdownShimmer(),
                      error: (err, _) => Text(err.toString(), style: const TextStyle(color: Colors.red)),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Button Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: activeCommoditiesAsync.when(
                data: (allCommodities) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canShowAdvisory ? const Color(0xFFF97316) : Colors.grey[300],
                        foregroundColor: Colors.white,
                        elevation: canShowAdvisory ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: canShowAdvisory
                          ? () {
                              final selectedCommoditiesList = allCommodities
                                  .where((c) => _selectedCommodityIds.contains(c.id))
                                  .toList();

                              List<int>? explicitMarketIds;
                              int? targetDistrictId;

                              if (_selectedMarketIds.isNotEmpty) {
                                explicitMarketIds = _selectedMarketIds.toList();
                              } else if (_selectedDistrictId != null) {
                                targetDistrictId = _selectedDistrictId;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExploreAdvisoryResultsScreen(
                                    selectedCommodities: selectedCommoditiesList,
                                    selectedMarketIds: explicitMarketIds,
                                    districtId: targetDistrictId,
                                  ),
                                ),
                              );
                            }
                          : null,

                      child: Text(
                        l10n.showAdvisory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(height: 52),
                error: (_, __) => const SizedBox(height: 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFF97316)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStateDropdown(List<StateModel> states, String languageCode) {
    StateModel? selectedStateObj;
    if (_selectedStateId != null) {
      try {
        selectedStateObj = states.firstWhere((s) => s.id == _selectedStateId);
      } catch (_) {}
    }

    return FilterDropdownButton<StateModel>(
      hintText: AppLocalizations.of(context)!.selectState,
      items: states,
      value: selectedStateObj,
      itemToString: (state) => state.getDisplayName(languageCode),
      width: double.infinity,
      onChanged: (value) {
        setState(() {
          _selectedStateId = value?.id;
          _selectedDistrictId = null;
          _selectedMarketIds.clear();
        });
      },
    );
  }

  Widget _buildDistrictDropdown(List<District> districts, String languageCode) {
    District? selectedDistrictObj;
    if (_selectedDistrictId != null) {
      try {
        selectedDistrictObj = districts.firstWhere((d) => d.id == _selectedDistrictId);
      } catch (_) {}
    }

    return FilterDropdownButton<District>(
      hintText: AppLocalizations.of(context)!.selectDistrict,
      items: districts,
      value: selectedDistrictObj,
      itemToString: (district) => district.getDisplayName(languageCode),
      width: double.infinity,
      onChanged: (value) {
        setState(() {
          _selectedDistrictId = value?.id;
          _selectedMarketIds.clear();
        });
      },
    );
  }


  Widget _buildMarketsSelector(List<Market> markets, String languageCode) {
    final filteredMarkets = markets.where((m) {
      if (_marketSearchQuery.isEmpty) return true;
      return m.name.toLowerCase().contains(_marketSearchQuery.toLowerCase());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0CC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) => setState(() => _marketSearchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search markets...',
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (filteredMarkets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No markets found', style: TextStyle(color: Color(0xFF6B7280))),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredMarkets.map((m) {
                final isSelected = _selectedMarketIds.contains(m.id);
                return FilterChip(
                  label: Text(m.name),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFF2E7),
                  checkmarkColor: const Color(0xFFF97316),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFF97316) : const Color(0xFF374151),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMarketIds.add(m.id);
                      } else {
                        _selectedMarketIds.remove(m.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommoditiesSelector(List<Commodity> commodities, String languageCode) {
    final filteredCommodities = commodities.where((c) {
      if (_commoditySearchQuery.isEmpty) return true;
      final name = c.getDisplayName(languageCode);
      return name.toLowerCase().contains(_commoditySearchQuery.toLowerCase());
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0CC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) => setState(() => _commoditySearchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search active crops...',
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (filteredCommodities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No crops found', style: TextStyle(color: Color(0xFF6B7280))),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredCommodities.map((c) {
                final isSelected = _selectedCommodityIds.contains(c.id);
                final displayName = c.getDisplayName(languageCode);
                return FilterChip(
                  label: Text(displayName),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFF2E7),
                  checkmarkColor: const Color(0xFFF97316),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFF97316) : const Color(0xFF374151),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCommodityIds.add(c.id);
                      } else {
                        _selectedCommodityIds.remove(c.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDisabledField(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      ),
    );
  }

  Widget _buildDropdownShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.orange[100]!,
      highlightColor: Colors.orange[50]!,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
