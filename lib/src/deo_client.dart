import 'package:dio/dio.dart';

import 'config/config.dart';
import 'errors/errors.dart';
import 'interceptors/interceptors.dart';

/// DeoClient is the main class for handling HTTP requests with advanced features
/// such as concurrent request handling, comprehensive error management, and
/// request cancellation.
class DeoClient {
  late final Dio _dio;
  late final DeoConfig _config;
  final Map<String, CancelToken> _cancelTokens = {};

  DeoClient({
    DeoConfig? config,
    Dio? dio,
  }) {
    _config = config ?? DeoConfig();
    _dio = dio ?? Dio();
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      sendTimeout: _config.sendTimeout,
    );

    // Add default interceptors
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Adds a custom interceptor to the client
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Performs a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _getCancelToken(cancelToken),
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }

  /// Performs a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _getCancelToken(cancelToken),
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }

  /// Performs a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _getCancelToken(cancelToken),
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }

  /// Performs a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _getCancelToken(cancelToken),
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }

  /// Performs a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _getCancelToken(cancelToken),
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }

  /// Cancels a request using the provided token
  void cancelRequest(String token) {
    if (_cancelTokens.containsKey(token)) {
      _cancelTokens[token]?.cancel('Request cancelled');
      _cancelTokens.remove(token);
    }
  }

  /// Gets or creates a cancel token for the given key
  CancelToken _getCancelToken(String? key) {
    if (key == null) return CancelToken();
    
    if (!_cancelTokens.containsKey(key)) {
      _cancelTokens[key] = CancelToken();
    }
    return _cancelTokens[key]!;
  }


  /// Performs multiple requests concurrently
  Future<List<Response>> concurrent(List<Future<Response> Function()> requests) async {
    try {
      final responses = await Future.wait(requests.map((req) => req()));
      return responses;
    } catch (e) {
      if (e is DioException) {
        throw DeoError.fromDioError(e);
      }
      throw DeoError(message: e.toString());
    }
  }
}