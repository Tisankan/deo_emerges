// No imports needed here

/// Configuration class for DeoClient that handles all network-related settings
class DeoConfig {
  /// Base URL for all requests
  final String baseUrl;

  /// Connection timeout duration in milliseconds
  final Duration connectTimeout;

  /// Receive timeout duration in milliseconds
  final Duration receiveTimeout;

  /// Send timeout duration in milliseconds
  final Duration sendTimeout;

  /// Maximum number of concurrent requests
  final int maxConcurrentRequests;

  /// Maximum number of retries for failed requests
  final int maxRetries;

  /// Whether to enable SSL certificate validation
  final bool validateCertificate;

  /// SSL certificates for pinning
  final List<String> certificates;

  /// Whether to enable request/response logging
  final bool enableLogging;

  /// Creates a new instance of [DeoConfig] with customizable network settings
  const DeoConfig({
    this.baseUrl = '',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxConcurrentRequests = 5,
    this.maxRetries = 3,
    this.validateCertificate = false,
    this.certificates = const [],
    this.enableLogging = true,
  });

  /// Creates a copy of this configuration with the given fields replaced with new values
  DeoConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    int? maxConcurrentRequests,
    int? maxRetries,
    bool? validateCertificate,
    List<String>? certificates,
    bool? enableLogging,
  }) {
    return DeoConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      maxConcurrentRequests: maxConcurrentRequests ?? this.maxConcurrentRequests,
      maxRetries: maxRetries ?? this.maxRetries,
      validateCertificate: validateCertificate ?? this.validateCertificate,
      certificates: certificates ?? this.certificates,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}