import 'market_directory_model.dart';

class PaginatedMarketResponse {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalRecords;
  final List<MarketDirectory> data;

  PaginatedMarketResponse({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
    required this.data,
  });

  factory PaginatedMarketResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedMarketResponse(
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
      totalRecords: json['total_records'],
      data: (json['data'] as List)
          .map((item) => MarketDirectory.fromJson(item))
          .toList(),
    );
  }
}
