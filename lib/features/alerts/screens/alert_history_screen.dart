import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/alert_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/alert_providers.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chips.dart';

class AlertHistoryScreen extends ConsumerStatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  ConsumerState<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends ConsumerState<AlertHistoryScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(alertHistoryNotifierProvider.notifier).loadNextPage();
    }
  }

  Map<String, List<Alert>> _groupAlertsByDate(List<Alert> alerts, AppLocalizations l10n) {
    final Map<String, List<Alert>> groups = {};
    final now = DateTime.now();

    for (final alert in alerts) {
      final localDt = alert.createdAt.toLocal();
      final isToday = localDt.year == now.year &&
          localDt.month == now.month &&
          localDt.day == now.day;

      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday = localDt.year == yesterday.year &&
          localDt.month == yesterday.month &&
          localDt.day == yesterday.day;

      String label;
      if (isToday) {
        label = l10n.today;
      } else if (isYesterday) {
        label = l10n.yesterday;
      } else {
        label = DateFormat('d MMMM yyyy').format(localDt);
      }

      groups.putIfAbsent(label, () => []).add(alert);
    }

    return groups;
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.0, color: Colors.red.shade400),
          const SizedBox(height: 12.0),
          Text(
            l10n.failedToLoadAlertHistory,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(alertHistoryNotifierProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27A32D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 56.0, color: Colors.grey.shade400),
          const SizedBox(height: 16.0),
          Text(
            l10n.noAlertsFound,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(alertHistoryNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.alertHistory,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertHistoryNotifierProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(alertHistoryNotifierProvider.notifier).setSearch(val);
                },
                decoration: InputDecoration(
                  hintText: l10n.searchAlerts,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF27A32D)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(alertHistoryNotifierProvider.notifier)
                                .setSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF27A32D), width: 1.5),
                  ),
                ),
              ),
            ),

            // Filter Chips
            AlertFilterChips(
              selectedFilter: state.selectedFilter,
              onSelected: (filter) {
                ref.read(alertHistoryNotifierProvider.notifier).setFilter(filter);
              },
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return _buildShimmerLoading();
                  }

                  if (state.error != null && state.alerts.isEmpty) {
                    return _buildErrorWidget(state.error!, l10n);
                  }

                  if (state.alerts.isEmpty) {
                    return _buildEmptyWidget(l10n);
                  }

                  final groupedAlerts = _groupAlertsByDate(state.alerts, l10n);
                  final groupKeys = groupedAlerts.keys.toList();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 24.0),
                    itemCount: groupKeys.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < groupKeys.length) {
                        final groupLabel = groupKeys[index];
                        final alertsInGroup = groupedAlerts[groupLabel]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 6.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14.0,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    groupLabel,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...alertsInGroup.map((alert) => AlertCard(alert: alert)),
                          ],
                        );
                      }

                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF27A32D),
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
