import 'package:flutter_test/flutter_test.dart';

// Kita paksa import class AuthTokensModel meskipun fisiknya belum ada! (Fase RED)
import 'package:news_app_mvvm/features/auth/data/models/auth_tokens_model.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: AuthTokensModel
/// -------------------------------------------------------------
/// File ini bertugas mengawal tulang punggung parser JSON dari backend!
/// Di file inilah Contract Testing terhadap API sebenarnya terjadi.
/// 
/// Kebutuhan (Requirements):
/// 1. [fromJson]: Harus sanggup mem-parsing Map JSON spesifik yang berisi
///    `access_token` dan `refresh_token` (sesuai dokumen Postman `free-api-news`),
///    lalu me-return objek yang murni (Value Object).
/// 2. [toJson]: Jika API kita sesekali butuh melempar token kembali (misal
///    waktu Logout), model ini harus bisa di-revert utuh kembali menjadi Map JSON.
/// -------------------------------------------------------------

void main() {
  const tAuthTokensModel = AuthTokensModel(
    accessToken: 'eyJhbG_ACCESS_TOKEN_PALSU',
    refreshToken: 'def456_REFRESH_TOKEN_PALSU',
  );

  group('AuthTokensModel JSON Parsing', () {
    test('harus berhasil membuat model yang akurat saat disuntik Json Map asli', () {
      // 1. ARRANGE
      // Ini adalah representasi murni JSON asli saat merayap keluar dari response['data'] api anda
      final Map<String, dynamic> tJsonMapAsli = {
        "access_token": "eyJhbG_ACCESS_TOKEN_PALSU",
        "refresh_token": "def456_REFRESH_TOKEN_PALSU"
      };

      // 2. ACT
      // Memicu function model yang bakal kita buat
      final result = AuthTokensModel.fromJson(tJsonMapAsli);

      // 3. ASSERT
      // Buktikan hasilnya 100% sama dengan tAuthTokensModel yang di atas!
      expect(result, tAuthTokensModel);
    });

    test('harus men-translate kembali objek ke bentuk Map JSON (untuk logout payload dll)', () {
      // 1. ARRANGE
      // (Kita cukup menggunakan tAuthTokensModel yang sudah siap)

      // 2. ACT
      final result = tAuthTokensModel.toJson();

      // 3. ASSERT
      final expectedJsonMap = {
        "access_token": "eyJhbG_ACCESS_TOKEN_PALSU",
        "refresh_token": "def456_REFRESH_TOKEN_PALSU"
      };
      expect(result, expectedJsonMap);
    });
  });
}
