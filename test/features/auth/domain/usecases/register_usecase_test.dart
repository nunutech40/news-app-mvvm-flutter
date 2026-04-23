import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUseCase(mockAuthRepository);
  });

  const tName = 'Budi';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthTokens = AuthTokens(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_123',
  );

  test('harus mengembalikan AuthTokens ketika register berhasil', () async {
    // arrange
    when(() => mockAuthRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tAuthTokens));

    // act
    final result = await usecase(const RegisterParams(
      name: tName,
      email: tEmail,
      password: tPassword,
    ));

    // assert
    expect(result, const Right(tAuthTokens));
    verify(() => mockAuthRepository.register(
          name: tName,
          email: tEmail,
          password: tPassword,
        )).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('harus mengembalikan ServerFailure ketika register gagal dari backend', () async {
    // arrange
    const tFailure = ServerFailure(message: 'Email sudah digunakan');
    when(() => mockAuthRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const RegisterParams(
      name: tName,
      email: tEmail,
      password: tPassword,
    ));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.register(
          name: tName,
          email: tEmail,
          password: tPassword,
        )).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
