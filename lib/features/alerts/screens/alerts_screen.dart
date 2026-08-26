import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/alert_providers.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chips.dart';
import 'alert_history_screen.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertsNotifierProvider.notifier).markAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(alertsNotifierProvider.notifier).loadNextPage();
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlertHistoryScreen()),
    );
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
            l10n.failedToLoadAlerts,
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
              ref.read(alertsNotifierProvider.notifier).refresh();
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
          Icon(Icons.notifications_off_outlined, size: 56.0, color: Colors.grey.shade400),
          const SizedBox(height: 16.0),
          Text(
            l10n.noAlerts,
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
    final state = ref.watch(alertsNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        title: Text(
          l10n.alertsScreen,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _navigateToHistory,
            icon: const Icon(Icons.history, size: 20, color: Color(0xFF27A32D)),
            label: Text(
              l10n.alertHistory,
              style: const TextStyle(
                color: Color(0xFF27A32D),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertsNotifierProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Filter categories
            AlertFilterChips(
              selectedFilter: state.selectedFilter,
              onSelected: (filter) {
                ref.read(alertsNotifierProvider.notifier).setFilter(filter);
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

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 24.0),
                    itemCount: state.alerts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 6.0),
                          child: Text(
                            l10n.todaysAlerts,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        );
                      }

                      final alertIndex = index - 1;
                      if (alertIndex < state.alerts.length) {
                        final alert = state.alerts[alertIndex];
                        return AlertCard(alert: alert);
                      }

                      // Bottom loader when loading more
                      if (state.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF27A32D),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
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
