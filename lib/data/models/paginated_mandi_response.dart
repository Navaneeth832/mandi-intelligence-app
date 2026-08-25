import 'mandi_price.dart';

class PaginatedMandiResponse {
  final int page;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final List<MandiPrice> data;

  PaginatedMandiResponse({
    required this.page,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedMandiResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedMandiResponse(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalRecords: json['total_records'] as int,
      totalPages: json['total_pages'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => MandiPrice.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total_records': totalRecords,
      'total_pages': totalPages,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
