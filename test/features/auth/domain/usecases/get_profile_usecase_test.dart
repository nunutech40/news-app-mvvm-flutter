import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/get_profile_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetProfileUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetProfileUseCase(mockAuthRepository);
  });

  const tUser = User(
    id: 1,
    name: 'Budi',
    email: 'budi@test.com',
    avatarUrl: '',
  );

  test('harus meneruskan pemanggilan getProfile ke AuthRepository', () async {
    // 1. ARRANGE
    when(() => mockAuthRepository.getProfile())
        .thenAnswer((_) async => const Right(tUser));

    // 2. ACT
    final result = await usecase(const NoParams());

    // 3. ASSERT
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.getProfile()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('harus mengembalikan Failure dari AuthRepository jika gagal', () async {
    // 1. ARRANGE
    const tFailure = ServerFailure(message: 'Token basi');
    when(() => mockAuthRepository.getProfile())
        .thenAnswer((_) async => const Left(tFailure));

    // 2. ACT
    final result = await usecase(const NoParams());

    // 3. ASSERT
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.getProfile()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
