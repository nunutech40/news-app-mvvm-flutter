import 'package:dartz/dartz.dart';
import 'package:news_app_mvvm/core/error/failures.dart';
import 'package:news_app_mvvm/core/usecases/usecase.dart';
import 'package:news_app_mvvm/features/news/domain/entities/article.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';

class GetBookmarksUseCase implements UseCase<List<Article>, NoParams> {
  final NewsRepository repository;

  GetBookmarksUseCase(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(NoParams params) async {
    return await repository.getBookmarks();
  }
}
