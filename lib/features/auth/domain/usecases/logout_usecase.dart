import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
