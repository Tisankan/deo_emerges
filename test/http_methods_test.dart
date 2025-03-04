import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:deo_emerges/deo_emerges.dart';

// Generate mocks
@GenerateMocks([Dio])
import 'http_methods_test.mocks.dart';

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

  group('DeoClient additional HTTP methods', () {
    final responsePayload = {'success': true, 'data': 'test data'};

    test('PUT request should complete successfully', () async {
      final requestData = {'name': 'test', 'value': 123};

      when(mockDio.put<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responsePayload,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          ));

      final response = await deoClient.put<Map<String, dynamic>>(
        '/test',
        data: requestData,
      );

      expect(response.statusCode, 200);
      expect(response.data, responsePayload);
      verify(mockDio.put<Map<String, dynamic>>(
        '/test',
        data: requestData,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });

    test('DELETE request should complete successfully', () async {
      when(mockDio.delete<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responsePayload,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          ));

      final response = await deoClient.delete<Map<String, dynamic>>('/test');

      expect(response.statusCode, 200);
      expect(response.data, responsePayload);
      verify(mockDio.delete<Map<String, dynamic>>(
        '/test',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).called(1);
    });

    test('PATCH request should complete successfully', () async {
      final requestData = {'name': 'updated'};

      when(mockDio.patch<Map<String, dynamic>>(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: responsePayload,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          ));

      final response = await deoClient.patch<Map<String, dynamic>>(
        '/test',
        data: requestData,
      );

      expect(response.statusCode, 200);
      expect(response.data, responsePayload);
      verify(mockDio.patch<Map<String, dynamic>>(
        '/test',
        data: requestData,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });

    test('HTTP methods should handle query parameters', () async {
      final queryParams = {'filter': 'active', 'sort': 'name'};

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

      final response = await deoClient.get<Map<String, dynamic>>(
        '/test',
        queryParameters: queryParams,
      );

      expect(response.statusCode, 200);
      expect(response.data, responsePayload);
      verify(mockDio.get<Map<String, dynamic>>(
        '/test',
        queryParameters: queryParams,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).called(1);
    });
  });
}
