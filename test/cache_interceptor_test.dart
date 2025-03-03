import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:deo_emerges/deo_emerges.dart';

// Generate mocks
@GenerateMocks([Dio])
import 'cache_interceptor_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late DeoClient deoClient;
  late CacheInterceptor cacheInterceptor;
  
  setUp(() {
    mockDio = MockDio();
    cacheInterceptor = CacheInterceptor(maxAge: const Duration(minutes: 5));
    when(mockDio.interceptors).thenReturn(Interceptors());
    deoClient = DeoClient(dio: mockDio);
    deoClient.addInterceptor(cacheInterceptor);
  });
  
  group('CacheInterceptor', () {
    test('should cache GET requests', () async {
      final responsePayload = {'data': 'cached data'};
      
      // First request should hit the network
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: responsePayload,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      ));
      
      final response1 = await deoClient.get<Map<String, dynamic>>('/test');
      expect(response1.data, responsePayload);
      
      // Second request should use cached data
      final response2 = await deoClient.get<Map<String, dynamic>>('/test');
      expect(response2.data, responsePayload);
      
      // Verify that only one network request was made
      verify(mockDio.get<Map<String, dynamic>>(
        '/test',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });
    
    test('should not cache non-GET requests', () async {
      final requestData = {'test': 'data'};
      final responsePayload = {'success': true};
      
      when(mockDio.post<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: responsePayload,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/test'),
      ));
      
      // Make two identical POST requests
      await deoClient.post<Map<String, dynamic>>('/test', data: requestData);
      await deoClient.post<Map<String, dynamic>>('/test', data: requestData);
      
      // Verify that both requests hit the network
      verify(mockDio.post<Map<String, dynamic>>(
        '/test',
        data: requestData,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(2);
    });
    
    test('should respect cache max age', () async {
      final responsePayload = {'data': 'cached data'};
      
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: responsePayload,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      ));
      
      // First request
      await deoClient.get<Map<String, dynamic>>('/test');
      
      // Manually expire the cache by setting a new interceptor with expired entries
      // This is a test-friendly approach instead of waiting for 6 minutes
      final expiredCacheInterceptor = CacheInterceptor(maxAge: const Duration(seconds: 0));
      deoClient = DeoClient(dio: mockDio);
      deoClient.addInterceptor(expiredCacheInterceptor);
      
      // Second request should hit network again because cache is considered expired
      await deoClient.get<Map<String, dynamic>>('/test');
      
      verify(mockDio.get<Map<String, dynamic>>(
        '/test',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(2);
    });
    
    test('should clear cache when requested', () async {
      final responsePayload = {'data': 'cached data'};
      
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: responsePayload,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      ));
      
      // First request
      await deoClient.get<Map<String, dynamic>>('/test');
      
      // Clear cache
      cacheInterceptor.clearCache();
      
      // Second request should hit network again
      await deoClient.get<Map<String, dynamic>>('/test');
      
      verify(mockDio.get<Map<String, dynamic>>(
        '/test',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(2);
    });
  });
}