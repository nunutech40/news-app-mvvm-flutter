import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:news_app_mvvm/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class FakeLoginParams extends Fake implements LoginParams {}
class FakeRegisterParams extends Fake implements RegisterParams {}
class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthViewModel viewModel;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockLogoutUseCase = MockLogoutUseCase();

    viewModel = AuthViewModel(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      getProfileUseCase: mockGetProfileUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthTokens = AuthTokens(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_123',
  );
  const tUser = User(
    id: 1,
    name: 'Budi',
    email: 'test@example.com',
    avatarUrl: 'https://example.com/avatar.png',
  );

  group('checkAuthStatus', () {
    test('harus set isInitialized=true dan currentUser apabila sesi aktif', () async {
      when(() => mockGetProfileUseCase(any()))
          .thenAnswer((_) async => const Right(tUser));

      expect(viewModel.isInitialized, isFalse);

      await viewModel.checkAuthStatus();

      expect(viewModel.isInitialized, isTrue);
      expect(viewModel.currentUser, tUser);
      expect(viewModel.isAuthenticated, isTrue);
      
      verify(() => mockGetProfileUseCase(any())).called(1);
    });

    test('harus set isInitialized=true dan currentUser=null apabila tidak ada sesi', () async {
      when(() => mockGetProfileUseCase(any()))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'No cache')));

      await viewModel.checkAuthStatus();

      expect(viewModel.isInitialized, isTrue);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isAuthenticated, isFalse);
      
      verify(() => mockGetProfileUseCase(any())).called(1);
    });
  });

  group('login', () {
    test('harus set currentUser ketika login dan getProfile berhasil', () async {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Right(tAuthTokens));
      when(() => mockGetProfileUseCase(any()))
          .thenAnswer((_) async => const Right(tUser));

      await viewModel.login(tEmail, tPassword);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.currentUser, tUser);
      expect(viewModel.isAuthenticated, isTrue);

      verify(() => mockLoginUseCase(any())).called(1);
      verify(() => mockGetProfileUseCase(any())).called(1);
    });

    test('harus set errorMessage ketika login gagal', () async {
      when(() => mockLoginUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Invalid credentials')));

      await viewModel.login(tEmail, tPassword);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Invalid credentials');
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isAuthenticated, isFalse);

      verify(() => mockLoginUseCase(any())).called(1);
      verifyNever(() => mockGetProfileUseCase(any()));
    });
  });

  group('register', () {
    const tName = 'Budi';
    
    test('harus set currentUser ketika register dan getProfile berhasil', () async {
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => const Right(tAuthTokens));
      when(() => mockGetProfileUseCase(any()))
          .thenAnswer((_) async => const Right(tUser));

      await viewModel.register(name: tName, email: tEmail, password: tPassword);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.currentUser, tUser);
      expect(viewModel.isAuthenticated, isTrue);

      verify(() => mockRegisterUseCase(any())).called(1);
      verify(() => mockGetProfileUseCase(any())).called(1);
    });

    test('harus set errorMessage ketika register gagal', () async {
      when(() => mockRegisterUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Email terdaftar')));

      await viewModel.register(name: tName, email: tEmail, password: tPassword);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Email terdaftar');
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isAuthenticated, isFalse);

      verify(() => mockRegisterUseCase(any())).called(1);
      verifyNever(() => mockGetProfileUseCase(any()));
    });
  });

  group('logout', () {
    test('harus set currentUser menjadi null ketika logout berhasil', () async {
      when(() => mockLogoutUseCase(any()))
          .thenAnswer((_) async => const Right(null));

      await viewModel.logout();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isAuthenticated, isFalse);

      verify(() => mockLogoutUseCase(any())).called(1);
    });
  });
}
