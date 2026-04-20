import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: ApiClientTest
/// -------------------------------------------------------------
/// Kebutuhan (Requirements) yang Diupgrade:
/// 1. [Mocking Dio]: Wajib.
/// 2. [Success Behavior]: Jika API call sukses, ApiClient sekarang 
///    diharapkan langsung melakukan ekstrak/parsing `response.data` 
///    menjadi Map<String, dynamic>. Ini mencegah layer lain repot meng-casting.
/// 3. [Failure Behavior]: WAJIB membungkus raw `DioException` menjadi 
///    Custom Domain Exception kita sendiri: `ServerException` atau `NetworkException`.
/// -------------------------------------------------------------

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    // Menggunakan injection test constructor (ini akan kita ubah di green phase)
    apiClient = ApiClient(dio: mockDio);
  });

  group('Melakukan HTTP GET', () {
    const tPath = '/top-headlines';
    final tResponseData = {'status': 'ok', 'articles': []};
    
    test('harus mengembalikan Map data apabila panggilan berhasil', () async {
      // 1. ARRANGE
      // Mock HTTP 200 dengan data tResponseData
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: tPath),
          ));

      // 2. ACT
      // Memanggil method GET
      final result = await apiClient.get(tPath);

      // 3. ASSERT
      // Buktikan hasilnya langsung berupa Map, BUKAN lagi objek *Response* dari Dio.
      expect(result, tResponseData);
      
      verify(() => mockDio.get(
            tPath,
            queryParameters: null,
            options: null,
            cancelToken: null,
            onReceiveProgress: null,
          )).called(1);
      verifyNoMoreInteractions(mockDio);
    });

    test('harus mengubah DioException.badResponse menjadi ServerException', () async {
      // 1. ARRANGE
      // Mocking Dio melempar respon error Server 500
      final tDioError = DioException(
        requestOptions: RequestOptions(path: tPath),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: tPath),
          statusCode: 500,
          data: {'message': 'Ini error dari server backend'},
        ),
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(tDioError);

      // 2. ACT
      final call = apiClient.get(tPath);

      // 3. ASSERT
      // ApiClient harus menelan DioException, 
      // lalu memuntahkannya kembali sebagai ServerException!
      expect(() => call, throwsA(isA<ServerException>().having((e) => e.message, 'message', 'Ini error dari server backend')));
    });
    
    test('harus mengubah DioException.connectionTimeout menjadi NetworkException', () async {
      // 1. ARRANGE
      final tTimeoutError = DioException(
        requestOptions: RequestOptions(path: tPath),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          )).thenThrow(tTimeoutError);

      // 2. ACT
      final call = apiClient.get(tPath);

      // 3. ASSERT
      expect(() => call, throwsA(isA<NetworkException>()));
    });
  });
}

