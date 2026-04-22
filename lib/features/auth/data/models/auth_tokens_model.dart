import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: AuthTokensModel
/// -------------------------------------------------------------
/// Data Layer! Kelas ini adalah turunan (anak) dari Entity AuthTokens.
/// Tugas khususnya HANYALAH menjadi jembatan terjemahan (Mapper)
/// dari bahasa Mesin (JSON Map) menuju Entity (bahasa Domain).
/// Karena sifat dari turunan (extends), model ini sah dikirim balik
/// ke UI/Domain sebagai Entity.
/// -------------------------------------------------------------
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  /// Factory untuk merakit Objek Model ini dari ledakan JSON Map mentah.
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    // ---> 1. AREA LOGIKA MILIK FACTORY <---
    // Cek apakah backend tiba-tiba iseng menghilangkan key 'access_token'
    if (!json.containsKey('access_token') || json['access_token'] == null) {
      throw const FormatException("Gawat! Backend tidak mengirimkan access_token dalam JSON!");
    }

    // Ekstrak dan bersihkan data (trim) barangkali dari internet ketambahan spasi ga sengaja
    final bersihAccessToken = (json['access_token'] as String).trim();
    
    // Fallback: Jika refresh token kebetulan null, kita isi string kosong daripada bikin crash aplikasi
    final bersihRefreshToken = (json['refresh_token'] as String?)?.trim() ?? '';

    // ---> 2. AREA PENYERAHAN KE DEFAULT CONSTRUCTOR <---
    return AuthTokensModel(
      accessToken: bersihAccessToken,
      refreshToken: bersihRefreshToken,
    );
  }

  /// Membungkus balik objek murni TDD ini kembali ke bahasa mesin (JSON Map)
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
