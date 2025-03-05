import 'package:dio/dio.dart';
import 'dart:io' show SocketException;

/// Base class for all errors in the Deo package
class DeoError implements Exception {
  /// Error message
  final String message;

  /// HTTP status code if applicable
  final int? statusCode;

  /// Original error that caused this error
  final dynamic originalError;

  /// Request data that caused this error
  final dynamic requestData;

  /// Response data received with this error
  final dynamic responseData;

  /// Error type classification
  final DeoErrorType type;

  /// Creates a new [DeoError] instance
  DeoError({
    required this.message,
    this.statusCode,
    this.originalError,
    this.requestData,
    this.responseData,
    this.type = DeoErrorType.unknown,
  });

  /// Creates a [DeoError] from a [DioException]
  factory DeoError.fromDioError(DioException error) {
    DeoErrorType errorType;
    int? statusCode = error.response?.statusCode;
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorType = DeoErrorType.timeout;
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorType = DeoErrorType.timeout;
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorType = DeoErrorType.timeout;
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        if (statusCode != null) {
          if (statusCode >= 500) {
            errorType = DeoErrorType.serverError;
            message = 'Server error: $statusCode';
          } else if (statusCode >= 400) {
            errorType = DeoErrorType.clientError;
            message = 'Client error: $statusCode';
          } else {
            errorType = DeoErrorType.unknown;
            message = 'Unexpected status code: $statusCode';
          }
        } else {
          errorType = DeoErrorType.unknown;
          message = 'Bad response with no status code';
        }
        break;
      case DioExceptionType.cancel:
        errorType = DeoErrorType.cancelled;
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorType = DeoErrorType.network;
        message = 'Connection error';
        break;
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          errorType = DeoErrorType.network;
          message = 'Network error: No internet connection';
        } else {
          errorType = DeoErrorType.unknown;
          message = error.message ?? 'Unknown error';
        }
        break;
    }

    return DeoError(
      message: message,
      statusCode: statusCode,
      originalError: error,
      requestData: error.requestOptions.data,
      responseData: error.response?.data,
      type: errorType,
    );
  }

  @override
  String toString() => 'DeoError: $message (${type.name})';
}

/// Enum representing different types of errors that can occur
enum DeoErrorType {
  /// Network-related errors (e.g., no internet connection)
  network,

  /// Timeout errors (connection, send, or receive timeout)
  timeout,

  /// Client-side errors (4xx status codes)
  clientError,

  /// Server-side errors (5xx status codes)
  serverError,

  /// Request was cancelled
  cancelled,

  /// Unknown or unclassified errors
  unknown,
}

/// Extension methods for [DeoErrorType]
extension DeoErrorTypeExtension on DeoErrorType {
  /// Returns true if the error is retryable
  bool get isRetryable {
    switch (this) {
      case DeoErrorType.network:
      case DeoErrorType.timeout:
      case DeoErrorType.serverError:
        return true;
      case DeoErrorType.clientError:
      case DeoErrorType.cancelled:
      case DeoErrorType.unknown:
        return false;
    }
  }
}

/// Exception thrown when a request is cancelled
class RequestCancelledException extends DeoError {
  RequestCancelledException({
    String message = 'Request was cancelled',
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
          type: DeoErrorType.cancelled,
        );
}

/// Exception thrown when a request times out
class RequestTimeoutException extends DeoError {
  RequestTimeoutException({
    String message = 'Request timed out',
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
          type: DeoErrorType.timeout,
        );
}


/// Exception thrown when there is a network errors
class NetworkException extends DeoError {
  NetworkException({
    String message = 'Network error occurred',
    dynamic originalError,
  }) : super(
          message: message,
          originalError: originalError,
          type: DeoErrorType.network,
        );
}
