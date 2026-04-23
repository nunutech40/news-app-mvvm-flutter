import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/auth_tokens.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthTokens, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthTokens>> call(LoginParams params) {
    // Sama seperti Future Forwarding sebelumnya,
    // kita tidak butuh async/await di sini karena kita cuma "mengoper"
    // eksekusi ke Repository.
    return repository.login(email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
