import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import komponen nyata: (Pastikan path-nya benar!)
import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';

// Import target yang belum dibikin (Inilah sebabnya test ini akan merah total!)
import 'package:news_app_mvvm/features/auth/data/datasources/auth_remote_data_source.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: AuthRemoteDataSource
/// -------------------------------------------------------------
/// File ini men-test lapisan Datasource untuk Auth (Login).
/// Tugas layer ini sederhana: 
/// Dia mengambil password & email mentah dari lapisan atas,
/// melemparnya ke [ApiClient], lalu mengekstrak "token" dari balasan server.
/// 
/// Kebutuhan (Requirements):
/// 1. Jika API sukses (HTTP 200), harus mengekstrak field 'token' dari JSON
///    dan me-return-nya sebagai String.
/// 2. Jika API gagal (Throws ServerException), layer ini harus membiarkan
///    Exception tersebut diteruskan (tidak ditelan).
/// -------------------------------------------------------------

// Bikin Mock dari kelas murni ApiClient kita!
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('Login System di Datasource', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    // Anggap saja Endpoint backend API kita membalas dengan struktur map seperti ini
    final tJsonResponsePayload = {
      'status': 'success',
      'data': {
        'token': 'bearer_token_super_rahasia_12345',
        'user': {
          'id': 1,
          'name': 'Budi'
        }
      }
    };
    
    test('harus mereturn Token (String) apabila login berhasil', () async {
      // 1. ARRANGE
      // Instruksikan si Tuyul: "Setiap ada request POST ke '/login' bawa body apapun, balas pake JSON sukses ini!"
      when(() => mockApiClient.post(
            '/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => tJsonResponsePayload);

      // 2. ACT
      final result = await dataSource.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      // Buktikan bahwa data yang dikeluarkan adalah murni string token
      expect(result, 'bearer_token_super_rahasia_12345');
      
      // Keamanan ganda: Buktikan email dan password terkirim dengan benar ke dalam body POST
      verify(() => mockApiClient.post(
            '/login',
            data: {
              'email': tEmail,
              'password': tPassword,
            },
          )).called(1);
    });

    test('harus memancarkan kembali ServerException apabila gagal login', () async {
      // 1. ARRANGE
      // ApiClient error melempar ServerException
      when(() => mockApiClient.post(
            '/login',
            data: any(named: 'data'),
          )).thenThrow(const ServerException(message: 'Email tidak ditemukan', statusCode: 404));

      // 2. ACT
      // Jangan taruh 'await' karena kita men-test Exception
      final call = dataSource.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });
}
