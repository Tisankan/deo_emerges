/// Base file for exporting all models

/// Model for representing a network request
class DeoRequest {
  /// The HTTP method (GET, POST, PUT, DELETE, etc.)
  final String method;
  
  /// The URL path
  final String path;
  
  /// Query parameters
  final Map<String, dynamic>? queryParameters;
  
  /// Request body data
  final dynamic data;
  
  /// Request headers
  final Map<String, dynamic>? headers;
  
  /// Extra options for the request
  final Map<String, dynamic>? extra;
  
  /// Creates a new [DeoRequest] instance
  const DeoRequest({
    required this.method,
    required this.path,
    this.queryParameters,
    this.data,
    this.headers,
    this.extra,
  });
  
  /// Creates a copy of this request with the given fields replaced with new values
  DeoRequest copyWith({
    String? method,
    String? path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
  }) {
    return DeoRequest(
      method: method ?? this.method,
      path: path ?? this.path,
      queryParameters: queryParameters ?? this.queryParameters,
      data: data ?? this.data,
      headers: headers ?? this.headers,
      extra: extra ?? this.extra,
    );
  }
}

/// Model for representing a network response
class DeoResponse<T> {
  /// The response data
  final T? data;
  
  /// Response headers
  final Map<String, List<String>> headers;
  
  /// HTTP status code
  final int statusCode;
  
  /// Whether the request was successful (status code 2xx)
  final bool isSuccess;
  
  /// The original request that produced this response
  final DeoRequest? request;
  
  /// Creates a new [DeoResponse] instance
  DeoResponse({
    this.data,
    required this.headers,
    required this.statusCode,
    this.request,
  }) : isSuccess = statusCode >= 200 && statusCode < 300;
  
  /// Creates a successful response
  factory DeoResponse.success({
    T? data,
    Map<String, List<String>>? headers,
    int statusCode = 200,
    DeoRequest? request,
  }) {
    return DeoResponse(
      data: data,
      headers: headers ?? {},
      statusCode: statusCode,
      request: request,
    );
  }
  
  /// Creates an error response
  factory DeoResponse.error({
    T? data,
    Map<String, List<String>>? headers,
    int statusCode = 500,
    DeoRequest? request,
  }) {
    return DeoResponse(
      data: data,
      headers: headers ?? {},
      statusCode: statusCode,
      request: request,
    );
  }
}

/// Model for representing pagination information
class PaginationInfo {
  /// The current page number
  final int currentPage;
  
  /// The total number of pages
  final int totalPages;
  
  /// The total number of items
  final int totalItems;
  
  /// The number of items per page
  final int perPage;
  
  /// Whether there is a next page
  final bool hasNextPage;
  
  /// Whether there is a previous page
  final bool hasPreviousPage;
  
  /// Creates a new [PaginationInfo] instance
  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  }) : 
    hasNextPage = currentPage < totalPages,
    hasPreviousPage = currentPage > 1;
  
  /// Creates a [PaginationInfo] from a JSON map
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      perPage: json['per_page'] ?? 10,
    );
  }
  
  /// Converts this [PaginationInfo] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'per_page': perPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}

/// Model for representing a paginated response
class PaginatedResponse<T> {
  /// The list of items
  final List<T> items;
  
  /// Pagination information
  final PaginationInfo pagination;
  
  /// Creates a new [PaginatedResponse] instance
  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });
  
  /// Creates a [PaginatedResponse] from a JSON map
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    final List<T> items = itemsJson
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();
    
    return PaginatedResponse(
      items: items,
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
  
  /// Converts this [PaginatedResponse] to a JSON map
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'pagination': pagination.toJson(),
    };
  }
}