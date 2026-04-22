import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';

// Mock Dependencies
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockSharedPreferences = MockSharedPreferences();
    dataSource = AuthLocalDataSourceImpl(
      secureStorage: mockSecureStorage,
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('AuthLocalDataSource - Tokens (SecureStorage)', () {
    const tAccessToken = 'access_123';
    const tRefreshToken = 'refresh_123';

    test('harus berhasil menyimpan (saveTokens) ke SecureStorage', () async {
      // 1. ARRANGE
      // (Terjemahan: Karena write itu void, kita harus mengatur mocktail untuk tidak melakukan apa-apa saat fungsi ini dipanggil)
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async => Future.value());

      // 2. ACT
      await dataSource.saveTokens(
        accessToken: tAccessToken,
        refreshToken: tRefreshToken,
      );

      // 3. ASSERT
      // (Terjemahan: Bukti validasi bahwa metode write dipanggil 2 kali untuk access_token dan refresh_token)
      verify(() => mockSecureStorage.write(key: 'ACCESS_TOKEN', value: tAccessToken)).called(1);
      verify(() => mockSecureStorage.write(key: 'REFRESH_TOKEN', value: tRefreshToken)).called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });

    test('harus memancarkan CacheException apabila gagal menyimpan token', () async {
      // 1. ARRANGE
      when(() => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenThrow(Exception('Storage penuh'));

      // 2. ACT
      final call = dataSource.saveTokens(
        accessToken: tAccessToken,
        refreshToken: tRefreshToken,
      );

      // 3. ASSERT
      expect(() => call, throwsA(isA<CacheException>()));
    });
  });

  group('AuthLocalDataSource - Profile (SharedPreferences)', () {
    const tUserModel = UserModel(
      id: 1,
      name: 'Budi',
      email: 'budi@test.com',
      avatarUrl: 'https://avatar.png',
    );

    test('harus berhasil memanggil setString ketika cacheProfile', () async {
      // 1. ARRANGE
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // 2. ACT
      await dataSource.cacheProfile(tUserModel);

      // 3. ASSERT
      final expectedJsonString = json.encode(tUserModel.toJson());
      verify(() => mockSharedPreferences.setString('CACHED_USER_PROFILE', expectedJsonString)).called(1);
    });

    test('harus mengembalikan UserModel apabila getCachedProfile ada isinya', () async {
      // 1. ARRANGE
      final tJsonString = json.encode(tUserModel.toJson());
      when(() => mockSharedPreferences.getString(any())).thenReturn(tJsonString);

      // 2. ACT
      final result = await dataSource.getCachedProfile();

      // 3. ASSERT
      expect(result, equals(tUserModel));
      verify(() => mockSharedPreferences.getString('CACHED_USER_PROFILE')).called(1);
    });

    test('harus memancarkan CacheException apabila getCachedProfile kosong (null)', () async {
      // 1. ARRANGE
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      // 2. ACT
      final call = dataSource.getCachedProfile();

      // 3. ASSERT
      expect(() => call, throwsA(isA<CacheException>()));
    });
  });
}
