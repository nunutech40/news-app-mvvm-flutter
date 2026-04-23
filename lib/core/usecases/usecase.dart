import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app_mvvm/core/error/failures.dart';

/// Base class untuk semua UseCase di dalam aplikasi.
/// UseCase bertugas mengeksekusi 1 tugas bisnis spesifik.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Digunakan jika UseCase tidak membutuhkan parameter apapun.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
