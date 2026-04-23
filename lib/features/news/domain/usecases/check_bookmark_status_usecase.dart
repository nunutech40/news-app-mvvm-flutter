import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class CheckBookmarkStatusUseCase implements UseCase<bool, String> {
  final NewsRepository repository;

  CheckBookmarkStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String slug) async {
    return await repository.isBookmarked(slug);
  }
}
