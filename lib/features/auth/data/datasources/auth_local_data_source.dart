import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
  Future<void> cacheProfile(UserModel user);
  Future<UserModel> getCachedProfile();
}

const cachedUserProfileKey = 'CACHED_USER_PROFILE';
const accessTokenKey = 'ACCESS_TOKEN';
const refreshTokenKey = 'REFRESH_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(key: accessTokenKey, value: accessToken);
      await secureStorage.write(key: refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens to secure storage');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await secureStorage.delete(key: accessTokenKey);
      await secureStorage.delete(key: refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear tokens');
    }
  }

  @override
  Future<void> cacheProfile(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(cachedUserProfileKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache profile data');
    }
  }

  @override
  Future<UserModel> getCachedProfile() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserProfileKey);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      } else {
        throw CacheException(message: 'No cached profile found');
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Failed to read cached profile');
    }
  }
}
