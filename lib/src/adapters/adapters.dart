import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riverpod/riverpod.dart';

import '../deo_client.dart';
import '../errors/errors.dart';

/// This file contains all the adapter implementations directly to avoid circular dependencies

/// Provider adapter for integrating DeoClient with the Provider package
class DeoProviderAdapter extends ChangeNotifier {
  final DeoClient _client;
  bool _isLoading = false;
  DeoError? _error;

  DeoProviderAdapter(this._client);

  /// The underlying DeoClient instance
  DeoClient get client => _client;

  /// Whether a request is currently in progress
  bool get isLoading => _isLoading;

  /// The most recent error, if any
  DeoError? get error => _error;

  /// Executes a request and handles loading state and errors
  Future<T?> execute<T>(Future<T> Function() request) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();
      
      final result = await request();
      _setLoading(false);
      return result;
    } catch (e) {
      _setLoading(false);
      _error = e is DeoError ? e : DeoError(message: e.toString());
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clears any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Riverpod adapter for integrating DeoClient with the Riverpod package
class DeoRiverpodAdapter extends StateNotifier<DeoState> {
  final DeoClient _client;

  DeoRiverpodAdapter(this._client) : super(DeoState.initial());

  /// The underlying DeoClient instance
  DeoClient get client => _client;

  /// Executes a request and handles state changes
  Future<T?> execute<T>(Future<T> Function() request) async {
    state = DeoState.loading();

    try {
      final result = await request();
      state = DeoState.success();
      return result;
    } catch (e) {
      final error = e is DeoError ? e : DeoError(message: e.toString());
      state = DeoState.error(error);
      return null;
    }
  }

  /// Resets the state to initial
  void reset() {
    state = DeoState.initial();
  }
}

/// State class for the Riverpod adapter
class DeoState {
  final bool isLoading;
  final bool isSuccess;
  final DeoError? error;

  const DeoState({
    required this.isLoading,
    required this.isSuccess,
    this.error,
  });

  /// Creates an initial state
  factory DeoState.initial() => const DeoState(
        isLoading: false,
        isSuccess: false,
      );

  /// Creates a loading state
  factory DeoState.loading() => const DeoState(
        isLoading: true,
        isSuccess: false,
      );

  /// Creates a success state
  factory DeoState.success() => const DeoState(
        isLoading: false,
        isSuccess: true,
      );

  /// Creates an error state
  factory DeoState.error(DeoError error) => DeoState(
        isLoading: false,
        isSuccess: false,
        error: error,
      );

  /// Creates a copy of this state with the given fields replaced with new values
  DeoState copyWith({
    bool? isLoading,
    bool? isSuccess,
    DeoError? error,
  }) {
    return DeoState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

/// Bloc adapter for integrating DeoClient with the Bloc package
class DeoBlocAdapter extends Cubit<DeoState> {
  final DeoClient _client;

  DeoBlocAdapter(this._client) : super(DeoState.initial());

  /// The underlying DeoClient instance
  DeoClient get client => _client;

  /// Executes a request and handles state changes
  Future<T?> execute<T>(Future<T> Function() request) async {
    emit(DeoState.loading());

    try {
      final result = await request();
      emit(DeoState.success());
      return result;
    } catch (e) {
      final error = e is DeoError ? e : DeoError(message: e.toString());
      emit(DeoState.error(error));
      return null;
    }
  }

  /// Resets the state to initial
  void reset() {
    emit(DeoState.initial());
  }
}

/// Provider for DeoClient
final deoClientProvider = Provider<DeoClient>((ref) {
  return DeoClient();
});

/// Provider for DeoProviderAdapter
final deoProviderAdapterProvider = Provider<DeoProviderAdapter>((ref) {
  final client = ref.watch(deoClientProvider);
  return DeoProviderAdapter(client);
});

/// StateNotifierProvider for DeoRiverpodAdapter
final deoRiverpodAdapterProvider =
    StateNotifierProvider<DeoRiverpodAdapter, DeoState>((ref) {
  final client = ref.watch(deoClientProvider);
  return DeoRiverpodAdapter(client);
});