import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, User> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(User user) async {
    return await repository.updateProfile(user);
  }
}
