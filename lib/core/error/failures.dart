import 'package:equatable/equatable.dart';

/// Base class untuk semua kembalian error (Left side of Either).
/// Wajib diturunkan dari [Equatable] agar bisa lolos saat pengujian *Expect*
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Mewakili error yang dilemparkan akibat respon backend mati/kacau.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode}) : super(message: message);

  // Jika statusCode juga dimasukkan ke props, Equatable akan menuntut
  // baik [message] dan [statusCode] untuk sama persis saat dibandingkan.
  @override
  List<Object?> get props => [message, statusCode];
}

/// Mewakili error yang dilemparkan akibat koneksi terputus/timeout di device user.
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}
