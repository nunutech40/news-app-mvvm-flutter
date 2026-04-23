import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/login_usecase.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: LoginUseCase
/// -------------------------------------------------------------
/// UseCase ini sangat sederhana, ia hanya meneruskan panggilan ke
/// AuthRepository tanpa menambah logika bisnis yang rumit.
/// -------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tAuthTokens = AuthTokens(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  test('harus meneruskan pemanggilan login ke AuthRepository dan mengembalikan Right(AuthTokens)', () async {
    // 1. ARRANGE
    when(() => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tAuthTokens));

    // 2. ACT
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // 3. ASSERT
    expect(result, const Right(tAuthTokens));
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('harus mengembalikan Failure dari AuthRepository jika login gagal', () async {
    // 1. ARRANGE
    const tFailure = ServerFailure(message: 'Invalid credentials');
    when(() => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Left(tFailure));

    // 2. ACT
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // 3. ASSERT
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
