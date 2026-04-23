import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: AuthRepository (Interface)
/// -------------------------------------------------------------
/// Ini adalah "Kontrak Kerja" (Interface) yang dibuat oleh Domain Layer.
/// Domain Layer (Bisnis/UI) hanya peduli dengan File ini. Mereka tidak
/// peduli siapa yang mengerjakan atau datanya dari mana (Remote/Local).
/// Semua metode harus mengembalikan Either<Failure, T>.
/// -------------------------------------------------------------
abstract class AuthRepository {
  Future<Either<Failure, AuthTokens>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthTokens>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, User>> updateProfile(User user);

  Future<Either<Failure, void>> logout();
}
