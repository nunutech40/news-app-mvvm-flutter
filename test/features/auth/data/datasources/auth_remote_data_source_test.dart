import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/features/auth/data/models/auth_tokens_model.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('AuthRemoteDataSource Login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    // Perbaikan: Contract JSON sesuai dengan Postman File
    final tJsonResponsePayload = {
      'success': true,
      'data': {
        'access_token': 'bearer_token_super_rahasia_12345',
        'refresh_token': 'refresh_12345'
      }
    };

    // Model yang diekspektasikan sebagai hasil keluaran dari DataSource
    const tAuthTokensModel = AuthTokensModel(
      accessToken: 'bearer_token_super_rahasia_12345',
      refreshToken: 'refresh_12345',
    );
    
    test('harus mereturn AuthTokensModel apabila login via ApiClient berhasil', () async {
      // 1. ARRANGE
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenAnswer((_) async => tJsonResponsePayload);

      // 2. ACT
      final result = await dataSource.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      expect(result, tAuthTokensModel);
      
      verify(() => mockApiClient.post(
            '/api/v1/auth/login',
            data: {
              'email': tEmail,
              'password': tPassword,
            },
            queryParameters: null,
            options: null,
            cancelToken: null,
            onSendProgress: null,
            onReceiveProgress: null
          )).called(1);
    });

    test('harus memancarkan ServerException apabila backend API melempar error', () async {
      // 1. ARRANGE
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenThrow(const ServerException(message: 'Email belum terdaftar', statusCode: 400));

      // 2. ACT
      final call = dataSource.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });

  group('AuthRemoteDataSource GetProfile', () {
    final tJsonResponsePayload = {
      'success': true,
      'data': {
        'id': 1,
        'name': 'Budi',
        'email': 'budi@test.com',
        'avatar_url': 'https://avatar.com/budi.png',
      }
    };

    const tUserModel = UserModel(
      id: 1,
      name: 'Budi',
      email: 'budi@test.com',
      avatarUrl: 'https://avatar.com/budi.png',
    );

    test('harus mereturn UserModel apabila getProfile via ApiClient berhasil', () async {
      // 1. ARRANGE
      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenAnswer((_) async => tJsonResponsePayload);

      // 2. ACT
      final result = await dataSource.getProfile();

      // 3. ASSERT
      expect(result, tUserModel);
      verify(() => mockApiClient.get(
            '/api/v1/auth/user', // Sesuaikan endpoint dengan postman jika berbeda
            queryParameters: null,
            options: null,
            cancelToken: null,
            onReceiveProgress: null
          )).called(1);
    });

    test('harus memancarkan ServerException apabila backend API melempar error saat getProfile', () async {
      // 1. ARRANGE
      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenThrow(const ServerException(message: 'Token expired', statusCode: 401));

      // 2. ACT
      final call = dataSource.getProfile();

      // 3. ASSERT
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });

  group('AuthRemoteDataSource Logout', () {
    const tRefreshToken = 'refresh_12345';
    final tJsonResponsePayload = {
      'success': true,
      'message': 'Successfully logged out'
    };

    test('harus berhasil (void) apabila logout via ApiClient sukses', () async {
      // 1. ARRANGE
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenAnswer((_) async => tJsonResponsePayload);

      // 2. ACT
      await dataSource.logout(refreshToken: tRefreshToken);

      // 3. ASSERT
      verify(() => mockApiClient.post(
            '/api/v1/auth/logout',
            data: {'refresh_token': tRefreshToken},
            queryParameters: null,
            options: null,
            cancelToken: null,
            onSendProgress: null,
            onReceiveProgress: null
          )).called(1);
    });

    test('harus memancarkan ServerException apabila backend melempar error saat logout', () async {
      // 1. ARRANGE
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress')
          )).thenThrow(const ServerException(message: 'Invalid Refresh Token', statusCode: 401));

      // 2. ACT
      final call = dataSource.logout(refreshToken: tRefreshToken);

      // 3. ASSERT
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });
}

