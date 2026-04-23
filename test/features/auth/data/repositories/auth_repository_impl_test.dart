import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/models/auth_tokens_model.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: AuthRepositoryImpl
/// -------------------------------------------------------------
/// Ini adalah pengujian untuk Sang Manajer (Repository).
/// Tugas utama Repository adalah:
/// 1. Mengorkestrasi Remote dan Local Data Source.
/// 2. Menangkap Exception dan mengubahnya menjadi Failure.
/// -------------------------------------------------------------

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password123';
    const tAuthTokensModel = AuthTokensModel(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );
    const AuthTokens tAuthTokens = tAuthTokensModel;

    test('harus mereturn data (Right) dan menyimpan token ke local saat login sukses', () async {
      // 1. ARRANGE
      // (Terjemahan: remote membalas sukses, local diam-diam nge-save tanpa error)
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tAuthTokensModel);
      when(() => mockLocalDataSource.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async => Future.value());

      // 2. ACT
      // (Terjemahan: Manajer mengeksekusi fungsi login)
      final result = await repository.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      // (Terjemahan: Validasi bahwa kembaliannya adalah kotak Kanan (Right) berisi Token,
      // lalu pastikan manajer benar-benar menyuruh local nyimpen token tersebut)
      expect(result, const Right(tAuthTokens));
      verify(() => mockRemoteDataSource.login(email: tEmail, password: tPassword)).called(1);
      verify(() => mockLocalDataSource.saveTokens(
            accessToken: tAuthTokensModel.accessToken,
            refreshToken: tAuthTokensModel.refreshToken,
          )).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('harus mereturn ServerFailure (Left) ketika remote melempar ServerException', () async {
      // 1. ARRANGE
      // (Terjemahan: remote nge-throw ServerException!)
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ServerException(message: 'Login Gagal'));

      // 2. ACT
      final result = await repository.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      // (Terjemahan: Pastikan ledakan tadi sudah diredam jadi botol ServerFailure)
      expect(result, const Left(ServerFailure(message: 'Login Gagal')));
      verify(() => mockRemoteDataSource.login(email: tEmail, password: tPassword)).called(1);
      // Pastikan kalau gagal, manajer TIDAK BOLEH menyuruh nyimpan token!
      verifyZeroInteractions(mockLocalDataSource); 
    });

    test('harus mereturn NetworkFailure (Left) ketika remote melempar NetworkException', () async {
      // 1. ARRANGE
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const NetworkException(message: 'Tidak ada internet'));

      // 2. ACT
      final result = await repository.login(email: tEmail, password: tPassword);

      // 3. ASSERT
      expect(result, const Left(NetworkFailure(message: 'Tidak ada internet')));
      verifyZeroInteractions(mockLocalDataSource);
    });
  });

  group('AuthRepository Register', () {
    const tName = 'Budi';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tAuthTokensModel = AuthTokensModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
    );
    const tAuthTokens = tAuthTokensModel;

    test('harus mereturn data AuthTokens ketika register berhasil', () async {
      // arrange
      when(() => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tAuthTokensModel);
      when(() => mockLocalDataSource.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.register(name: tName, email: tEmail, password: tPassword);

      // assert
      verify(() => mockRemoteDataSource.register(name: tName, email: tEmail, password: tPassword));
      verify(() => mockLocalDataSource.saveTokens(
            accessToken: tAuthTokensModel.accessToken,
            refreshToken: tAuthTokensModel.refreshToken,
          ));
      expect(result, equals(const Right(tAuthTokens)));
    });

    test('harus mereturn ServerFailure ketika register gagal dari remote', () async {
      // arrange
      when(() => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const ServerException(message: 'Email sudah terdaftar'));

      // act
      final result = await repository.register(name: tName, email: tEmail, password: tPassword);

      // assert
      verify(() => mockRemoteDataSource.register(name: tName, email: tEmail, password: tPassword));
      verifyZeroInteractions(mockLocalDataSource);
      expect(result, equals(const Left(ServerFailure(message: 'Email sudah terdaftar'))));
    });
  });

  group('getProfile', () {
    const tUserModel = UserModel(
      id: 1,
      name: 'Budi',
      email: 'budi@test.com',
      avatarUrl: '',
    );
    const User tUser = tUserModel;

    test('harus mereturn data User (Right) dan men-cache ke local saat sukses', () async {
      // 1. ARRANGE
      when(() => mockRemoteDataSource.getProfile())
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheProfile(any()))
          .thenAnswer((_) async => Future.value());

      // 2. ACT
      final result = await repository.getProfile();

      // 3. ASSERT
      expect(result, const Right(tUser));
      verify(() => mockRemoteDataSource.getProfile()).called(1);
      verify(() => mockLocalDataSource.cacheProfile(tUserModel)).called(1);
    });

    test('harus mereturn CacheFailure (Left) apabila gagal saat menyimpan cache', () async {
      // 1. ARRANGE
      // Skenario unik: Remote sukses bawa data, tapi Memori HP (Local) penuh/error
      when(() => mockRemoteDataSource.getProfile())
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheProfile(any()))
          .thenThrow(const CacheException(message: 'Storage Penuh'));

      // 2. ACT
      final result = await repository.getProfile();

      // 3. ASSERT
      // Meski dapet data, tapi karena gagal nge-save, Repository lapor failure
      expect(result, const Left(CacheFailure(message: 'Storage Penuh')));
    });

    test('harus membaca dari cache (Offline Fallback) apabila remote melempar ServerException', () async {
      // 1. ARRANGE
      when(() => mockRemoteDataSource.getProfile())
          .thenThrow(const ServerException(message: 'Server Mati'));
      when(() => mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tUserModel); // Ternyata di memori masih ada data lama

      // 2. ACT
      final result = await repository.getProfile();

      // 3. ASSERT
      expect(result, const Right(tUser));
      verify(() => mockRemoteDataSource.getProfile()).called(1);
      verify(() => mockLocalDataSource.getCachedProfile()).called(1);
    });

    test('harus membaca dari cache (Offline Fallback) apabila remote melempar NetworkException', () async {
      // 1. ARRANGE
      when(() => mockRemoteDataSource.getProfile())
          .thenThrow(const NetworkException(message: 'Tidak ada sinyal'));
      when(() => mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tUserModel);

      // 2. ACT
      final result = await repository.getProfile();

      // 3. ASSERT
      expect(result, const Right(tUser));
      verify(() => mockRemoteDataSource.getProfile()).called(1);
      verify(() => mockLocalDataSource.getCachedProfile()).called(1);
    });

    test('harus mereturn ServerFailure apabila remote gagal DAN cache lokal kosong', () async {
      // 1. ARRANGE
      when(() => mockRemoteDataSource.getProfile())
          .thenThrow(const ServerException(message: 'Server Mati'));
      // Skenario terburuk: Server mati, dan HP tidak punya cache sama sekali
      when(() => mockLocalDataSource.getCachedProfile())
          .thenThrow(const CacheException(message: 'No cache'));

      // 2. ACT
      final result = await repository.getProfile();

      // 3. ASSERT
      expect(result, const Left(ServerFailure(message: 'Server Mati')));
    });
  });

  group('logout', () {
    const tRefreshToken = 'refresh_token_123';

    test('harus memanggil remote logout dan clearAll lokal saat jalan mulus', () async {
      // 1. ARRANGE
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => tRefreshToken);
      when(() => mockRemoteDataSource.logout(refreshToken: any(named: 'refreshToken')))
          .thenAnswer((_) async => Future.value());
      when(() => mockLocalDataSource.clearAll())
          .thenAnswer((_) async => Future.value());

      // 2. ACT
      final result = await repository.logout();

      // 3. ASSERT
      expect(result, const Right(null));
      verify(() => mockLocalDataSource.getRefreshToken()).called(1);
      verify(() => mockRemoteDataSource.logout(refreshToken: tRefreshToken)).called(1);
      verify(() => mockLocalDataSource.clearAll()).called(1);
    });

    test('harus TETAP memanggil clearAll lokal (Sapu Jagat) meski remote melempar ServerException', () async {
      // 1. ARRANGE
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => tRefreshToken);
      when(() => mockRemoteDataSource.logout(refreshToken: any(named: 'refreshToken')))
          .thenThrow(const ServerException(message: 'Invalid token di server'));
      when(() => mockLocalDataSource.clearAll())
          .thenAnswer((_) async => Future.value());

      // 2. ACT
      final result = await repository.logout();

      // 3. ASSERT
      // Trik Sapu Jagat: Server bilang gagal, tapi di HP user tetap dianggap berhasil logout
      expect(result, const Right(null));
      verify(() => mockLocalDataSource.clearAll()).called(1);
    });
  });
}
