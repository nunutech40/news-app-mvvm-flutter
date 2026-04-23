import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  test('harus memanggil fungsi logout di dalam AuthRepository', () async {
    // 1. ARRANGE
    when(() => mockAuthRepository.logout())
        .thenAnswer((_) async => const Right(null));

    // 2. ACT
    final result = await usecase(const NoParams());

    // 3. ASSERT
    expect(result, const Right(null));
    verify(() => mockAuthRepository.logout()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('harus mengembalikan Failure dari AuthRepository jika logout gagal (Sad Path)', () async {
    // 1. ARRANGE
    const tFailure = ServerFailure(message: 'Gagal membersihkan sesi di server');
    when(() => mockAuthRepository.logout())
        .thenAnswer((_) async => const Left(tFailure));

    // 2. ACT
    final result = await usecase(const NoParams());

    // 3. ASSERT
    // Memastikan UseCase tidak menelan Failure, melainkan meneruskannya utuh ke atas
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.logout()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
