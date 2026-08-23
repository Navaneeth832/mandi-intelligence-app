import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/repositories/alert_repository.dart';

class AlertsState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String selectedFilter;
  final List<Alert> alerts;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNextPage;

  const AlertsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedFilter = 'ALL',
    this.alerts = const [],
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.hasNextPage = false,
  });

  AlertsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? selectedFilter,
    List<Alert>? alerts,
    int? page,
    int? pageSize,
    int? total,
    bool? hasNextPage,
    bool clearError = false,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      alerts: alerts ?? this.alerts,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class AlertsNotifier extends StateNotifier<AlertsState> {
  final AlertRepository _repository;
  final String _languageCode;

  AlertsNotifier(this._repository, this._languageCode) : super(const AlertsState()) {
    loadAlerts();
  }

  Future<void> loadAlerts({String? filter}) async {
    final activeFilter = filter ?? state.selectedFilter;
    state = state.copyWith(
      isLoading: true,
      selectedFilter: activeFilter,
      clearError: true,
      page: 1,
    );

    try {
      final res = await _repository.getAlerts(
        type: activeFilter,
        language: _languageCode,
        page: 1,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        alerts: res.items,
        page: res.page,
        total: res.total,
        hasNextPage: res.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    try {
      final res = await _repository.getAlerts(
        type: state.selectedFilter,
        language: _languageCode,
        page: nextPage,
        pageSize: state.pageSize,
      );

      final combined = [...state.alerts, ...res.items];
      state = state.copyWith(
        isLoadingMore: false,
        alerts: combined,
        page: res.page,
        total: res.total,
        hasNextPage: res.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> setFilter(String filter) async {
    if (state.selectedFilter == filter) return;
    await loadAlerts(filter: filter);
  }

  Future<void> refresh() async {
    await loadAlerts();
  }
}

class AlertHistoryState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String searchQuery;
  final String selectedFilter;
  final String? dateFrom;
  final String? dateTo;
  final List<Alert> alerts;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNextPage;

  const AlertHistoryState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery = '',
    this.selectedFilter = 'ALL',
    this.dateFrom,
    this.dateTo,
    this.alerts = const [],
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.hasNextPage = false,
  });

  AlertHistoryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    String? selectedFilter,
    String? dateFrom,
    String? dateTo,
    List<Alert>? alerts,
    int? page,
    int? pageSize,
    int? total,
    bool? hasNextPage,
    bool clearError = false,
    bool clearDateRange = false,
  }) {
    return AlertHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
      alerts: alerts ?? this.alerts,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class AlertHistoryNotifier extends StateNotifier<AlertHistoryState> {
  final AlertRepository _repository;
  final String _languageCode;

  AlertHistoryNotifier(this._repository, this._languageCode) : super(const AlertHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory({
    String? filter,
    String? search,
    String? dateFrom,
    String? dateTo,
    bool clearDateRange = false,
  }) async {
    final activeFilter = filter ?? state.selectedFilter;
    final activeSearch = search ?? state.searchQuery;
    final activeFrom = clearDateRange ? null : (dateFrom ?? state.dateFrom);
    final activeTo = clearDateRange ? null : (dateTo ?? state.dateTo);

    state = state.copyWith(
      isLoading: true,
      selectedFilter: activeFilter,
      searchQuery: activeSearch,
      dateFrom: activeFrom,
      dateTo: activeTo,
      clearError: true,
      clearDateRange: clearDateRange,
      page: 1,
    );

    try {
      final res = await _repository.getAlertHistory(
        type: activeFilter,
        search: activeSearch,
        dateFrom: activeFrom,
        dateTo: activeTo,
        language: _languageCode,
        page: 1,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        alerts: res.items,
        page: res.page,
        total: res.total,
        hasNextPage: res.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    try {
      final res = await _repository.getAlertHistory(
        type: state.selectedFilter,
        search: state.searchQuery,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        language: _languageCode,
        page: nextPage,
        pageSize: state.pageSize,
      );

      final combined = [...state.alerts, ...res.items];
      state = state.copyWith(
        isLoadingMore: false,
        alerts: combined,
        page: res.page,
        total: res.total,
        hasNextPage: res.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> setFilter(String filter) async {
    if (state.selectedFilter == filter) return;
    await loadHistory(filter: filter);
  }

  Future<void> setSearch(String query) async {
    if (state.searchQuery == query) return;
    await loadHistory(search: query);
  }

  Future<void> setDateRange(String? from, String? to) async {
    final isClearing = (from == null && to == null);
    state = state.copyWith(
      dateFrom: from,
      dateTo: to,
      clearDateRange: isClearing,
    );
    await loadHistory(
      dateFrom: from,
      dateTo: to,
      clearDateRange: isClearing,
    );
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}

final alertsNotifierProvider =
    StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  final repo = ref.watch(alertRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return AlertsNotifier(repo, locale.languageCode);
});

final alertHistoryNotifierProvider =
    StateNotifierProvider<AlertHistoryNotifier, AlertHistoryState>((ref) {
  final repo = ref.watch(alertRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return AlertHistoryNotifier(repo, locale.languageCode);
});
