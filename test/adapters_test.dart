import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:deo_emerges/deo_emerges.dart';

// Generate mocks
@GenerateMocks([DeoClient])
import 'adapters_test.mocks.dart';

void main() {
  group('DeoProviderAdapter', () {
    late MockDeoClient mockClient;
    late DeoProviderAdapter adapter;

    setUp(() {
      mockClient = MockDeoClient();
      adapter = DeoProviderAdapter(mockClient);
    });

    test('should initialize with client', () {
      expect(adapter.client, equals(mockClient));
      expect(adapter.isLoading, isFalse);
      expect(adapter.error, isNull);
    });

    test('should handle successful request', () async {
      bool loadingStateChanged = false;
      adapter.addListener(() {
        if (adapter.isLoading) {
          loadingStateChanged = true;
        }
      });

      final result = await adapter.execute(() async => 'success');

      expect(loadingStateChanged, isTrue);
      expect(adapter.isLoading, isFalse);
      expect(adapter.error, isNull);
      expect(result, equals('success'));
    });

    test('should handle error in request', () async {
      final deoError = DeoError(message: 'Test error');
      bool errorStateChanged = false;

      adapter.addListener(() {
        if (adapter.error != null) {
          errorStateChanged = true;
        }
      });

      final result = await adapter.execute(() async => throw deoError);

      expect(errorStateChanged, isTrue);
      expect(adapter.isLoading, isFalse);
      expect(adapter.error, equals(deoError));
      expect(result, isNull);
    });

    test('should handle non-DeoError in request', () async {
      final result =
          await adapter.execute(() async => throw Exception('Test exception'));

      expect(adapter.isLoading, isFalse);
      expect(adapter.error, isNotNull);
      expect(adapter.error?.message, contains('Test exception'));
      expect(result, isNull);
    });

    test('should clear error', () async {
      await adapter.execute(() async => throw DeoError(message: 'Test error'));
      expect(adapter.error, isNotNull);

      adapter.clearError();
      expect(adapter.error, isNull);
    });
  });

  group('DeoRiverpodAdapter', () {
    late MockDeoClient mockClient;
    late DeoRiverpodAdapter adapter;

    setUp(() {
      mockClient = MockDeoClient();
      adapter = DeoRiverpodAdapter(mockClient);
    });

    test('should initialize with initial state', () {
      expect(adapter.client, equals(mockClient));
      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, isNull);
    });

    test('should handle successful request', () async {
      final result = await adapter.execute(() async => 'success');

      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isTrue);
      expect(adapter.state.error, isNull);
      expect(result, equals('success'));
    });

    test('should handle error in request', () async {
      final deoError = DeoError(message: 'Test error');
      final result = await adapter.execute(() async => throw deoError);

      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, equals(deoError));
      expect(result, isNull);
    });

    test('should reset state', () async {
      await adapter.execute(() async => throw DeoError(message: 'Test error'));
      expect(adapter.state.error, isNotNull);

      adapter.reset();
      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, isNull);
    });
  });

  group('DeoBlocAdapter', () {
    late MockDeoClient mockClient;
    late DeoBlocAdapter adapter;

    setUp(() {
      mockClient = MockDeoClient();
      adapter = DeoBlocAdapter(mockClient);
    });

    test('should initialize with initial state', () {
      expect(adapter.client, equals(mockClient));
      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, isNull);
    });

    test('should handle successful request', () async {
      final result = await adapter.execute(() async => 'success');

      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isTrue);
      expect(adapter.state.error, isNull);
      expect(result, equals('success'));
    });

    test('should handle error in request', () async {
      final deoError = DeoError(message: 'Test error');
      final result = await adapter.execute(() async => throw deoError);

      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, equals(deoError));
      expect(result, isNull);
    });

    test('should reset state', () async {
      await adapter.execute(() async => throw DeoError(message: 'Test error'));
      expect(adapter.state.error, isNotNull);

      adapter.reset();
      expect(adapter.state.isLoading, isFalse);
      expect(adapter.state.isSuccess, isFalse);
      expect(adapter.state.error, isNull);
    });
  });
}
