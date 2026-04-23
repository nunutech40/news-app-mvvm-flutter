import 'package:flutter/foundation.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/update_profile_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _logoutUseCase = logoutUseCase;

  // --- States ---
  bool _isInitialized = false; // Status apakah Splash Screen sudah selesai ngecek
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // --- Getters ---
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // --- Actions ---

  /// Mengecek apakah user sudah login sebelumnya (dipanggil saat Splash Screen)
  Future<void> checkAuthStatus() async {
    // Sengaja dikasih delay sedikit agar logo Splash Screen sempat terlihat (opsional)
    await Future.delayed(const Duration(seconds: 1));

    final profileResult = await _getProfileUseCase(const NoParams());

    profileResult.fold(
      (failure) {
        // Gagal ambil profil lokal (berarti belum login atau sesi expired)
        _currentUser = null;
        _isInitialized = true;
        notifyListeners();
      },
      (user) {
        // Sukses baca profil dari cache
        _currentUser = user;
        _isInitialized = true;
        notifyListeners();
      },
    );
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final loginResult = await _loginUseCase(LoginParams(email: email, password: password));

    await loginResult.fold(
      (failure) async {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (authTokens) async {
        await _fetchProfileAfterAuth();
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      RegisterParams(name: name, email: email, password: password),
    );

    await result.fold(
      (failure) async {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (tokens) async {
        await _fetchProfileAfterAuth();
      },
    );
  }

  Future<void> _fetchProfileAfterAuth() async {
    final profileResult = await _getProfileUseCase(const NoParams());

    profileResult.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) {
        _isLoading = false;
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (success) {
        _isLoading = false;
        _currentUser = null;
        notifyListeners();
      },
    );
  }

  Future<void> updateProfile(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfileUseCase(user);

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (updatedUser) {
        _isLoading = false;
        _currentUser = updatedUser;
        notifyListeners();
      },
    );
  }
}
