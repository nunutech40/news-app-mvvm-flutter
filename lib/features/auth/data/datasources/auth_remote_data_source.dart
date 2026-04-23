import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/features/auth/data/models/auth_tokens_model.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Proses login yang akan me-return sepasang Token (Access & Refresh)
  /// jika sukses, atau memuntahkan Exception jika gagal.
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  });

  /// Proses registrasi akun baru
  Future<AuthTokensModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Mengambil data profil user yang sedang login
  Future<UserModel> getProfile();

  /// Memperbarui profil user
  Future<UserModel> updateProfile(UserModel user);

  /// Proses logout untuk menghancurkan sesi di server menggunakan refresh token
  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    // 1. Eksekusi Request ke Network via ApiClient Wrapper
    final response = await apiClient.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );

    // 2. Baca Contract Response Asli dari Backend
    if (response['success'] == true) {
      // Pasrahkan proses raw JSON Map menuju Objek ke AuthTokensModel
      return AuthTokensModel.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      // Lempar Exception dari server jika status tag-nya false
      throw ServerException(
        message:
            response['message'] as String? ??
            'Login failed due to unknown error',
      );
    }
  }

  @override
  Future<AuthTokensModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/api/v1/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    if (response['success'] == true) {
      return AuthTokensModel.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw ServerException(
        message:
            response['message'] as String? ??
            'Register failed due to unknown error',
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get('/api/v1/auth/user');

    if (response['success'] == true) {
      return UserModel.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw ServerException(
        message:
            response['message'] as String? ??
            'Failed to get profile due to unknown error',
      );
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final response = await apiClient.post(
      '/api/v1/auth/user',
      data: user.toJson(),
    );

    if (response['success'] == true) {
      return UserModel.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw ServerException(
        message: response['message'] as String? ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    final response = await apiClient.post(
      '/api/v1/auth/logout',
      data: {'refresh_token': refreshToken},
    );

    if (response['success'] == true) {
      return;
    } else {
      throw ServerException(
        message: response['message'] as String? ?? 'Logout failed due to unknown error',
      );
    }
  }
}
