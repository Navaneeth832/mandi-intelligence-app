import 'market_directory_model.dart';

class PaginatedMarketResponse {
  final int page;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<MarketDirectory> data;

  PaginatedMarketResponse({
    required this.page,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedMarketResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedMarketResponse(
      page: json['page'],
      pageSize: json['page_size'],
      totalRecords: json['total_records'],
      totalPages: json['total_pages'],
      data: (json['data'] as List)
          .map((item) => MarketDirectory.fromJson(item))
          .toList(),
    );
  }
}
