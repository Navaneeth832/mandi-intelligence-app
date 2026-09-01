import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';
import 'package:mandi_intelligence_app/core/providers/locale_provider.dart';
import '../../../data/models/district_model.dart';
import '../widgets/price_card.dart';
import '../widgets/filter_dropdown.dart';
import 'filter_results_screen.dart';
import 'market_detail_screen.dart';
import '../providers/filter_model.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';
import '../../alerts/widgets/notification_bell.dart';
import '../../auth/screens/notification_settings_screen.dart';
import '../../auth/providers/notification_preferences_provider.dart';
import '../../../core/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Temporary state for dropdowns
  String? _tempCrop;
  String? _tempState;
  String? _tempDistrict;
  String? _tempMarket;
  bool _isNotificationBannerDismissed = false;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      const filter = Filter();
      ref.read(mandiPricesProvider(filter).notifier).loadNextPage();
    }
  }

  void _applyFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterResultsScreen(
          selectedCrop: _tempCrop,
          selectedState: _tempState,
          selectedDistrict: _tempDistrict,
          selectedMarket: _tempMarket,
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _tempCrop = null;
      _tempState = null;
      _tempDistrict = null;
      _tempMarket = null;
    });
  }

  String getRelativeTime(BuildContext context, DateTime lastUpdated) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      return l10n.weeksAgo((difference.inDays / 7).floor());
    } else {
      return l10n.monthsAgo((difference.inDays / 30).floor());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Light grey background matching the design
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Icon(Icons.agriculture_outlined, color: Color.fromARGB(255, 39, 163, 45), size: 32),
          ],
        ),
        actions: const [
          NotificationBell(
            iconColor: Color.fromARGB(255, 39, 163, 45),
            iconSize: 28,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    const filter = Filter();

    final pricesAsync = ref.watch(mandiPricesProvider(filter));
    final currentState = pricesAsync.valueOrNull;

    final hasConfiguredAsync = ref.watch(hasConfiguredNotificationPreferencesProvider);
    final bool showNotificationBanner = hasConfiguredAsync.maybeWhen(
      data: (hasConfigured) => !hasConfigured && !_isNotificationBannerDismissed,
      orElse: () => false,
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the current filter
        ref.invalidate(mandiPricesProvider(filter));
        ref.invalidate(statesProvider);
        ref.invalidate(commoditiesProvider);
        ref.invalidate(marketsProvider);

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        children: [
          _buildHeaderSection(
            pricesAsync.maybeWhen(
              data: (state) =>
                  state.items.isNotEmpty
                      ? state.items.first.createdAt
                      : DateTime.now(),
              orElse: () => DateTime.now(),
            ),
          ),
          if (showNotificationBanner)
            _buildNotificationPreferencesBanner(),
          if (currentState?.isFromCache == true)
            _buildOfflineBanner(currentState?.cachedAt),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 20),
          _buildPriceList(filter),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF1D4ED8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set Up Notification Preferences',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Customize alerts for price changes and crop recommendations.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF1E40AF),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markNotificationPreferencesConfigured();
                    ref.invalidate(hasConfiguredNotificationPreferencesProvider);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Set preferences',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1D4ED8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              setState(() {
                _isNotificationBannerDismissed = true;
              });
              await ref
                  .read(notificationRepositoryProvider)
                  .markNotificationPreferencesConfigured();
              ref.invalidate(hasConfiguredNotificationPreferencesProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(DateTime? cachedAt) {
    final l10n = AppLocalizations.of(context)!;
    final timeAgoStr = cachedAt != null ? getRelativeTime(context, cachedAt) : l10n.justNow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Amber 100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.offlineLabel} · ${l10n.lastSyncedLabel(timeAgoStr)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(DateTime latestUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.hexagon, color: Color.fromARGB(255, 39, 163, 45), size: 68),
                Icon(Icons.arrow_upward, color: Colors.white, size: 32),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.liveMandiPrices,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!
                      .lastUpdated(getRelativeTime(context, latestUpdate)),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          )
        ),
      ],
    );
  }
Widget _buildFilterSection() {
  final locale = ref.watch(localeProvider);
  final cropsAsync = ref.watch(commodityListProvider);
  final statesAsync = ref.watch(statesProvider);

  final states = statesAsync.valueOrNull ?? [];

  // Find selected state ID
  StateModel? selectedStateObj;
  if (_tempState != null) {
    try {
      selectedStateObj = states.firstWhere(
        (s) => s.name == _tempState || s.getDisplayName(locale.languageCode) == _tempState,
      );
    } catch (_) {
      selectedStateObj = null;
    }
  }

  final districtsAsync = ref.watch(
    districtsProvider(
      selectedStateObj?.id,
    ),
  );

  District? selectedDistrictObj;
  if (_tempDistrict != null) {
    districtsAsync.whenData((districts) {
      try {
        selectedDistrictObj = districts.firstWhere(
          (d) => d.name == _tempDistrict || d.getDisplayName(locale.languageCode) == _tempDistrict,
        );
      } catch (_) {
        selectedDistrictObj = null;
      }
    });
  }

  final marketsAsync =
  ref.watch(
    marketsProvider(
      selectedDistrictObj?.id,
    ),
  );
  final bool hasFilters = _tempCrop != null || 
                          _tempState != null || 
                          _tempDistrict != null || 
                          _tempMarket != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: FilterDropdownButton<String>(
                hintText: AppLocalizations.of(context)!.commodity,
                items: cropsAsync.valueOrNull ?? [],
                value: _tempCrop,
                onChanged: (value) {
                  setState(() {
                    _tempCrop = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: Consumer(
                builder: (context, ref, _) {
                  final locale = ref.watch(localeProvider);
                  return FilterDropdownButton<StateModel>(
                    hintText: AppLocalizations.of(context)!.state,
                    items: states,
                    itemToString: (state) => state.getDisplayName(locale.languageCode),
                    value: selectedStateObj,
                    onChanged: (value) {
                      setState(() {
                        _tempState = value?.getDisplayName(locale.languageCode);
                        _tempDistrict = null;
                        _tempMarket = null;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            SizedBox(
              width: 160,
              child: Consumer(
                builder: (context, ref, _) {
                  final locale = ref.watch(localeProvider);
                  return FilterDropdownButton<District>(
                    hintText: AppLocalizations.of(context)!.district,
                    items: districtsAsync.maybeWhen(
                      data: (districts) => districts,
                      orElse: () => [],
                    ),
                    itemToString: (district) => district.getDisplayName(locale.languageCode),
                    value: selectedDistrictObj,
                    onChanged: (value) {
                      setState(() {
                        _tempDistrict = value?.getDisplayName(locale.languageCode);
                        _tempMarket = null;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: FilterDropdownButton<String>(
                hintText: AppLocalizations.of(context)!.market,
                items: marketsAsync.valueOrNull ?? [],
                value: _tempMarket,
                onChanged: (value) {
                  setState(() {
                    _tempMarket = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Buttons updated
      Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 39, 163, 45),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: hasFilters ? _applyFilters : null,
          child: Text(
            AppLocalizations.of(context)!.applyFilters,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: Localizations.localeOf(context).languageCode == 'ml'
                  ? 15
                  : 16,
              fontWeight:
                  Localizations.localeOf(context).languageCode == 'ml'
                      ? FontWeight.w600
                      : FontWeight.bold,
              height:
                  Localizations.localeOf(context).languageCode == 'ml'
                      ? 1.35
                      : 1.2,
            ),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: SizedBox(
        height: 64,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 39, 163, 45),
            side: const BorderSide(
              color: Color.fromARGB(255, 39, 163, 45),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: hasFilters ? _clearFilters : null,
          child: Text(
            AppLocalizations.of(context)!.clearAll,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: Localizations.localeOf(context).languageCode == 'ml'
                  ? 15
                  : 16,
              fontWeight:
                  Localizations.localeOf(context).languageCode == 'ml'
                      ? FontWeight.w600
                      : FontWeight.bold,
              height:
                  Localizations.localeOf(context).languageCode == 'ml'
                      ? 1.35
                      : 1.2,
            ),
          ),
        ),
      ),
    ),
  ],
)
      
    ],
  );
}

  Widget _buildPriceList(Filter filter) {
    final pricesAsync = ref.watch(mandiPricesProvider(filter));

    return pricesAsync.when(
      data: (state) {
        if (state.items.isEmpty) {
          return const EmptyStateWidget();
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final price = state.items[index];

                return PriceCard(
                  price: price,
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketDetailScreen(
                          price: price,
                        ),
                      ),
                    );
                                       },
                );
              },
            ),
            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 39, 163, 45),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (err, stack) => ErrorStateWidget(
        errorMessage: err.toString(),
        onRetry: () {
          ref.read(mandiPricesProvider(filter).notifier).loadInitialPage();
        },
      ),
    );
  }
}
