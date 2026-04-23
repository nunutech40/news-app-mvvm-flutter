import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: AuthRepositoryImpl
/// -------------------------------------------------------------
/// Ini adalah Manajer sungguhan yang bekerja di Data Layer.
/// Dia mengawasi dua pekerja: remoteDataSource dan localDataSource.
/// Di sinilah tempat segala ledakan (Exception) ditangkap dan
/// dibungkus menjadi Kotak Parsel (Failure).
/// -------------------------------------------------------------
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Manajer nyuruh Remote nge-hits API
      final remoteTokens = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Kalau sukses dan dapet Token, nyuruh Local nge-save
      await localDataSource.saveTokens(
        accessToken: remoteTokens.accessToken,
        refreshToken: remoteTokens.refreshToken,
      );

      // Kembalikan token ke UI (Dalam bentuk Kanan / Right)
      return Right(remoteTokens);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final remoteTokens = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      await localDataSource.saveTokens(
        accessToken: remoteTokens.accessToken,
        refreshToken: remoteTokens.refreshToken,
      );

      return Right(remoteTokens);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final remoteUser = await remoteDataSource.getProfile();
      await localDataSource.cacheProfile(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      // Offline Fallback: Coba baca dari memori lokal
      try {
        final cachedUser = await localDataSource.getCachedProfile();
        return Right(cachedUser);
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } on NetworkException catch (e) {
      // Offline Fallback: Coba baca dari memori lokal
      try {
        final cachedUser = await localDataSource.getCachedProfile();
        return Right(cachedUser);
      } catch (_) {
        return Left(NetworkFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      // Cast ke UserModel atau buat UserModel baru dari entity User
      final userModel = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        phone: user.phone,
        preferences: user.preferences,
      );

      final updatedUser = await remoteDataSource.updateProfile(userModel);
      await localDataSource.cacheProfile(updatedUser);
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // 1. Ambil refreshToken untuk dikirim ke API
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken: refreshToken);
      }
      // 2. Bersihkan memori HP
      await localDataSource.clearAll();
      return const Right(null);
    } on ServerException catch (_) {
      // Trik Sapu Jagat: Server meledak? Tetap hapus memori HP!
      await localDataSource.clearAll();
      return const Right(null);
    } on NetworkException catch (_) {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (_) {
      await localDataSource.clearAll();
      return const Right(null);
    }
  }
}
