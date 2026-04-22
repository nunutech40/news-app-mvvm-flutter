import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_mvvm/features/auth/data/models/auth_tokens_model.dart';

void main() {
  const tAuthTokensModel = AuthTokensModel(
    accessToken: 'eyJhbG_ACCESS_TOKEN_PALSU',
    refreshToken: 'def456_REFRESH_TOKEN_PALSU',
  );

  group('AuthTokensModel JSON Parsing', () {
    test('1. [Happy Path] harus berhasil parse Map JSON normal dan otomatis melakukan "trimming" spasi', () {
      // 1. ARRANGE
      // Sengaja kita masukkan spasi berlebihan untuk ngetes fungsi trim() satpam factory
      final Map<String, dynamic> tJsonMapKotor = {
        "access_token": "   eyJhbG_ACCESS_TOKEN_PALSU   ",
        "refresh_token": " def456_REFRESH_TOKEN_PALSU "
      };

      // 2. ACT
      final result = AuthTokensModel.fromJson(tJsonMapKotor);

      // 3. ASSERT
      // Meskipun kotor, hasilnya harus presisi bersih
      expect(result, tAuthTokensModel);
    });

    test('2. [Exception] harus melempar FormatException jika access_token tidak ada (Missing Key)', () {
      // 1. ARRANGE
      final Map<String, dynamic> tJsonTanpaAccessToken = {
        "refresh_token": "def456_REFRESH_TOKEN_PALSU"
      };

      // 2. ACT
      final call = () => AuthTokensModel.fromJson(tJsonTanpaAccessToken);

      // 3. ASSERT
      expect(call, throwsA(isA<FormatException>()));
    });

    test('3. [Exception] harus melempar FormatException jika access_token bernilai null', () {
      // 1. ARRANGE
      final Map<String, dynamic> tJsonNullAccessToken = {
        "access_token": null,
        "refresh_token": "def456_REFRESH_TOKEN_PALSU"
      };

      // 2. ACT
      final call = () => AuthTokensModel.fromJson(tJsonNullAccessToken);

      // 3. ASSERT
      expect(call, throwsA(isA<FormatException>()));
    });

    test('4. [Fallback] harus memberikan default fallback "" (string kosong) jika refresh_token null', () {
      // 1. ARRANGE
      final Map<String, dynamic> tJsonTanpaRefreshToken = {
        "access_token": "eyJhbG_ACCESS_TOKEN_PALSU",
        // refresh_token sengaja gak dimasukin
      };

      // 2. ACT
      final result = AuthTokensModel.fromJson(tJsonTanpaRefreshToken);

      // 3. ASSERT
      // Terbukti aplikasinya gak crash, dan field-nya diisi empty string!
      expect(result.accessToken, "eyJhbG_ACCESS_TOKEN_PALSU");
      expect(result.refreshToken, ""); 
    });

    test('5. [To JSON] harus bisa di-translate kembali menjadi Map Murni JSON', () {
      final result = tAuthTokensModel.toJson();
      final expectedJsonMap = {
        "access_token": "eyJhbG_ACCESS_TOKEN_PALSU",
        "refresh_token": "def456_REFRESH_TOKEN_PALSU"
      };
      expect(result, expectedJsonMap);
    });
  });
}
