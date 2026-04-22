import 'package:equatable/equatable.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: AuthTokens Entity
/// -------------------------------------------------------------
/// Ini adalah inti dari Clean Architecture Domain Layer!
/// Entity adalah murni urusan logika bisnis dan UI. Ia buta huruf
/// terhadap apa itu JSON, API, atau Firebase.
/// Ia hanya peduli satu hal: Aplikasi butuh token untuk bekerja!
/// -------------------------------------------------------------
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
