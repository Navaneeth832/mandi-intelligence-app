import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/market_comparison_model.dart';
import '../../../data/services/mandi_api_service.dart';

enum MarketSortOption {
  bestValue,
  netProfit,
  sellingPrice,
  distance,
  lowestTransport,
}

extension MarketSortOptionExtension on MarketSortOption {
  String get label {
    switch (this) {
      case MarketSortOption.bestValue:
        return '🏆 Best Value';
      case MarketSortOption.netProfit:
        return '🟢 Net Profit';
      case MarketSortOption.sellingPrice:
        return '💰 Highest Price';
      case MarketSortOption.distance:
        return '📍 Nearest';
      case MarketSortOption.lowestTransport:
        return '🚛 Lowest Transport';
    }
  }
}

class MarketComparisonState {
  final double lat;
  final double lng;
  final String locationLabel;
  final double quantity;
  final double transportRatePerKm;
  final MarketSortOption sortOption;
  final bool isLoading;
  final String? errorMessage;
  final MarketComparisonResponse? rawData;
  final List<MarketComparisonItem> sortedMarkets;

  MarketComparisonState({
    required this.lat,
    required this.lng,
    required this.locationLabel,
    required this.quantity,
    required this.transportRatePerKm,
    required this.sortOption,
    required this.isLoading,
    this.errorMessage,
    this.rawData,
    required this.sortedMarkets,
  });

  factory MarketComparisonState.initial() {
    return MarketComparisonState(
      lat: 9.5916,
      lng: 76.5222,
      locationLabel: 'Kottayam, Kerala (GPS Detected)',
      quantity: 10.0,
      transportRatePerKm: 2.5,
      sortOption: MarketSortOption.bestValue,
      isLoading: false,
      errorMessage: null,
      rawData: null,
      sortedMarkets: [],
    );
  }

  MarketComparisonState copyWith({
    double? lat,
    double? lng,
    String? locationLabel,
    double? quantity,
    double? transportRatePerKm,
    MarketSortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
    MarketComparisonResponse? rawData,
    List<MarketComparisonItem>? sortedMarkets,
  }) {
    return MarketComparisonState(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationLabel: locationLabel ?? this.locationLabel,
      quantity: quantity ?? this.quantity,
      transportRatePerKm: transportRatePerKm ?? this.transportRatePerKm,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      rawData: rawData ?? this.rawData,
      sortedMarkets: sortedMarkets ?? this.sortedMarkets,
    );
  }
}

class MarketComparisonNotifier extends StateNotifier<MarketComparisonState> {
  final MandiApiService _apiService;

  MarketComparisonNotifier(this._apiService) : super(MarketComparisonState.initial());

  Future<void> fetchComparison({
    int? commodityId,
    double? lat,
    double? lng,
    double? quantity,
  }) async {
    final targetLat = lat ?? state.lat;
    final targetLng = lng ?? state.lng;
    final targetQuantity = quantity ?? state.quantity;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lat: targetLat,
      lng: targetLng,
      quantity: targetQuantity,
    );

    try {
      final response = await _apiService.getMarketComparison(
        lat: targetLat,
        lng: targetLng,
        commodityId: commodityId,
        transportRatePerKm: state.transportRatePerKm,
        quantity: targetQuantity,
      );

      final sortedList = _sortMarkets(response.markets, state.sortOption);

      state = state.copyWith(
        isLoading: false,
        rawData: response,
        sortedMarkets: sortedList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load nearby mandi data. Please check your connection.',
      );
    }
  }

  void setSortOption(MarketSortOption option) {
    if (state.rawData == null) return;
    final sorted = _sortMarkets(state.rawData!.markets, option);
    state = state.copyWith(
      sortOption: option,
      sortedMarkets: sorted,
    );
  }

  void updateQuantity(double newQuantity, int? commodityId) {
    if (newQuantity <= 0) return;
    fetchComparison(
      commodityId: commodityId,
      quantity: newQuantity,
    );
  }

  void setCustomLocation({
    required double lat,
    required double lng,
    required String label,
    int? commodityId,
  }) {
    state = state.copyWith(locationLabel: label);
    fetchComparison(
      commodityId: commodityId,
      lat: lat,
      lng: lng,
    );
  }

  List<MarketComparisonItem> _sortMarkets(
    List<MarketComparisonItem> markets,
    MarketSortOption option,
  ) {
    final list = List<MarketComparisonItem>.from(markets);
    switch (option) {
      case MarketSortOption.bestValue:
      case MarketSortOption.netProfit:
        // Sort by highest net profit per quintal descending
        list.sort((a, b) => b.netProfit.compareTo(a.netProfit));
        break;
      case MarketSortOption.sellingPrice:
        // Sort by highest selling price descending
        list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case MarketSortOption.distance:
        // Sort by nearest distance ascending
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case MarketSortOption.lowestTransport:
        // Sort by lowest transport cost ascending
        list.sort((a, b) => a.transportCost.compareTo(b.transportCost));
        break;
    }
    return list;
  }
}

final mandiApiServiceProvider = Provider<MandiApiService>((ref) {
  return MandiApiService();
});

final marketComparisonProvider =
    StateNotifierProvider<MarketComparisonNotifier, MarketComparisonState>((ref) {
  final apiService = ref.watch(mandiApiServiceProvider);
  return MarketComparisonNotifier(apiService);
});
