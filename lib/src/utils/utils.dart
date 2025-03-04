import 'dart:convert';
import 'dart:io' show HttpClient;
import 'package:crypto/crypto.dart' as crypto;

/// Base file for exporting all utilities

/// Utility class for handling HTTP headers
class HeaderUtils {
  /// Creates common headers for JSON requests
  static Map<String, dynamic> jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Creates headers with authorization token
  static Map<String, dynamic> authHeaders(String token,
      {String prefix = 'Bearer'}) {
    return {
      ...jsonHeaders(),
      'Authorization': '$prefix $token',
    };
  }

  /// Merges multiple header maps
  static Map<String, dynamic> merge(List<Map<String, dynamic>> headers) {
    final result = <String, dynamic>{};
    for (final map in headers) {
      result.addAll(map);
    }
    return result;
  }
}

/// Utility class for handling URL operations
class UrlUtils {
  /// Builds a URL with query parameters
  static String buildUrl(String baseUrl, String path,
      [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse(baseUrl);
    final pathUri = Uri.parse(path);

    final newUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: pathUri.path,
      queryParameters: queryParams,
    );

    return newUri.toString();
  }

  /// Joins URL segments
  static String joinSegments(List<String> segments) {
    return segments
        .map((segment) => segment.trim().replaceAll(RegExp(r'^/|/$'), ''))
        .where((segment) => segment.isNotEmpty)
        .join('/');
  }
}

/// Utility class for data serialization
class SerializationUtils {
  /// Converts an object to JSON
  static String toJson(dynamic data) {
    return jsonEncode(data);
  }

  /// Parses JSON to an object
  static dynamic fromJson(String json) {
    return jsonDecode(json);
  }

  /// Converts a map to query parameters
  static String toQueryParams(Map<String, dynamic> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}

/// Utility class for security operations
class SecurityUtils {
  /// Generates an MD5 hash of the input string
  static String md5(String input) {
    return crypto.md5.convert(utf8.encode(input)).toString();
  }

  /// Generates a SHA-256 hash of the input string
  static String sha256(String input) {
    return crypto.sha256.convert(utf8.encode(input)).toString();
  }

  /// Generates a basic authentication header value
  static String basicAuth(String username, String password) {
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
}

/// Utility class for network connectivity
class ConnectivityUtils {
  /// Checks if a URL is reachable
  static Future<bool> isUrlReachable(String url,
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = timeout;
      final request = await client.headUrl(Uri.parse(url));
      final response = await request.close();
      await response.drain<void>();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Utility class for handling retry logic
class RetryUtils {
  /// Executes a function with retry logic
  static Future<T> withRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? retryIf,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await function();
      } catch (e) {
        if (e is! Exception ||
            attempts >= maxRetries ||
            (retryIf != null && !retryIf(e))) {
          rethrow;
        }

        attempts++;
        await Future.delayed(delay * attempts);
      }
    }
  }
}
