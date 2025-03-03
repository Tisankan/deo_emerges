import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:deo_emerges/deo_emerges.dart';

// Generate mocks
@GenerateMocks([Dio])
import 'deo_client_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late DeoClient deoClient;
  late Interceptors mockInterceptors;
  
  setUp(() {
    mockDio = MockDio();
    mockInterceptors = Interceptors();
    when(mockDio.interceptors).thenReturn(mockInterceptors);
    deoClient = DeoClient(dio: mockDio);
  });
  
  group('DeoClient initialization', () {
    test('should initialize with default config when no config is provided', () {
      final client = DeoClient(dio: mockDio);
      expect(client, isNotNull);
    });
    
    test('should initialize with custom config', () {
      final config = DeoConfig(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      );
      
      final client = DeoClient(config: config, dio: mockDio);
      expect(client, isNotNull);
    });
  });
  
  group('DeoClient HTTP methods', () {
    final responsePayload = {'success': true, 'data': 'test data'};
    
    test('GET request should complete successfully', () async {
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
      
      final response = await deoClient.get<Map<String, dynamic>>('/test');
      
      expect(response.statusCode, 200);
      expect(response.data, responsePayload);
      verify(mockDio.get<Map<String, dynamic>>(
        '/test',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });
    
    test('POST request should complete successfully', () async {
      final requestData = {'name': 'test', 'value': 123};
      
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
      
      final response = await deoClient.post<Map<String, dynamic>>(
        '/test',
        data: requestData,
      );
      
      expect(response.statusCode, 201);
      expect(response.data, responsePayload);
      verify(mockDio.post<Map<String, dynamic>>(
        '/test',
        data: requestData,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });
  });
  
  group('DeoClient error handling', () {
    test('should handle network errors correctly', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      ));
      
      expect(
        () => deoClient.get('/test'),
        throwsA(isA<DeoError>()),
      );
    });
    
    test('should handle non-DioException errors', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow('Unexpected error');
      
      expect(
        () => deoClient.get('/test'),
        throwsA(isA<DeoError>()),
      );
    });
  });
  
  group('DeoClient request cancellation', () {
    test('should cancel requests with the same token', () async {
      final cancelToken = CancelToken();
      
      // Setup the mock to store the cancel token
      CancelToken? storedToken;
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((invocation) {
        storedToken = invocation.namedArguments[Symbol('cancelToken')] as CancelToken?;
        return Future.value(Response<Map<String, dynamic>>(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        ));
      });
      
      // Make a request with a token
      await deoClient.get<Map<String, dynamic>>('/test', cancelToken: 'test-token');
      
      // Cancel the request
      deoClient.cancelRequest('test-token');
      
      // Verify the token was canceled
      expect(storedToken?.isCancelled, isTrue);
    });
  });
  
  group('DeoClient concurrent requests', () {
    test('should execute multiple requests concurrently', () async {
      // Setup mocks for two different requests
      when(mockDio.get<Map<String, dynamic>>(
        '/users',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: {'users': ['user1', 'user2']},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users'),
      ));
      
      when(mockDio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: {'products': ['product1', 'product2']},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/products'),
      ));
      
      // Execute concurrent requests
      final responses = await deoClient.concurrent([
        () => deoClient.get('/users'),
        () => deoClient.get('/products'),
      ]);
      
      // Verify responses
      expect(responses.length, 2);
      expect(responses[0].data, {'users': ['user1', 'user2']});
      expect(responses[1].data, {'products': ['product1', 'product2']});
    });
    
    test('should handle errors in concurrent requests', () async {
      // Setup one successful request and one that throws an error
      when(mockDio.get<Map<String, dynamic>>(
        '/users',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
        data: {'users': ['user1', 'user2']},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users'),
      ));
      
      when(mockDio.get<Map<String, dynamic>>(
        '/error',
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/error'),
      ));
      
      // Expect the concurrent call to throw a DeoError
      expect(
        () => deoClient.concurrent([
          () => deoClient.get('/users'),
          () => deoClient.get('/error'),
        ]),
        throwsA(isA<DeoError>()),
      );
    });
  });
}